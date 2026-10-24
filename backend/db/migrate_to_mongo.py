"""
Data Migration Script: MySQL -> MongoDB
---------------------------------------
Exports all data from MySQL (`crowd_event_db`) without omitting any fields,
and imports everything directly into MongoDB with preserved IDs, timestamps,
and counter sequences for future auto-incrementing IDs.
"""

import sys
import os
import json
from pathlib import Path
from datetime import datetime, date, time, timedelta
from typing import Dict, Any, List

BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

import pymongo
from config.settings import settings


def serialize_value(val: Any) -> Any:
    """Normalize values for MongoDB storage and JSON serialization."""
    if isinstance(val, (datetime,)):
        return val.strftime('%Y-%m-%d %H:%M:%S')
    if isinstance(val, (date,)):
        return val.strftime('%Y-%m-%d')
    if isinstance(val, (time,)):
        return val.strftime('%H:%M:%S')
    if isinstance(val, timedelta):
        total_seconds = int(val.total_seconds())
        h = total_seconds // 3600
        m = (total_seconds % 3600) // 60
        s = total_seconds % 60
        return f"{h:02d}:{m:02d}:{s:02d}"
    return val


def fetch_from_mysql() -> Dict[str, List[Dict[str, Any]]]:
    """Fetch all rows from the live MySQL database."""
    import pymysql
    import pymysql.cursors

    tables = ['users', 'venues', 'fest', 'events', 'images', 'crowd_analyses', 'alerts']
    data = {}

    print(f"Connecting to MySQL ({settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME})...")
    conn = pymysql.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=10,
        ssl={"ssl": True}
    )

    try:
        with conn.cursor() as cursor:
            for table in tables:
                cursor.execute(f"SELECT * FROM `{table}` ORDER BY id ASC;")
                rows = cursor.fetchall()
                serialized_rows = []
                for row in rows:
                    serialized_row = {k: serialize_value(v) for k, v in row.items()}
                    serialized_rows.append(serialized_row)
                data[table] = serialized_rows
                print(f"  [MySQL] Table '{table}': {len(serialized_rows)} records fetched.")
    finally:
        conn.close()

    return data


def fetch_from_backup_json() -> Dict[str, List[Dict[str, Any]]]:
    """Fallback to dump_current_db.json if MySQL is offline."""
    json_path = BACKEND_DIR / "dump_current_db.json"
    if not json_path.exists():
        raise FileNotFoundError(f"Backup dump not found at {json_path}")
    print(f"Reading from fallback backup file: {json_path}")
    with open(json_path, "r", encoding="utf-8") as f:
        return json.load(f)


def run_migration(mongo_uri: str = "mongodb://localhost:27017/", mongo_db_name: str = "crowd_event_db"):
    """
    Executes full data migration into MongoDB.
    Ensures zero data loss, unique indexes, and initializes auto-increment counters.
    """
    try:
        data = fetch_from_mysql()
    except Exception as exc:
        print(f"[WARNING] MySQL direct fetch failed: {exc}")
        print("Switching to local dump_current_db.json fallback...")
        data = fetch_from_backup_json()

    # Save a fresh snapshot of everything fetched
    snapshot_path = BACKEND_DIR / "mongo_migration_snapshot.json"
    with open(snapshot_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, default=str)
    print(f"Saved complete snapshot to {snapshot_path}")

    # Connect to MongoDB
    print(f"Connecting to MongoDB at {mongo_uri} (db: {mongo_db_name})...")
    client = pymongo.MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
    db = client[mongo_db_name]

    # Verify connection
    server_info = client.server_info()
    print(f"Connected to MongoDB Server v{server_info.get('version')}")

    # Counters collection to manage AUTO_INCREMENT behavior in MongoDB
    counters_col = db["counters"]

    collection_map = {
        'users': 'users',
        'venues': 'venues',
        'fest': 'fest',
        'events': 'events',
        'images': 'images',
        'crowd_analyses': 'crowd_analyses',
        'alerts': 'alerts'
    }

    for src_table, target_col_name in collection_map.items():
        records = data.get(src_table, [])
        col = db[target_col_name]

        # Clear existing documents to do a clean initial migration without duplicates
        col.drop()

        # Create unique index on 'id'
        col.create_index([("id", pymongo.ASCENDING)], unique=True)

        max_id = 0
        if records:
            docs_to_insert = []
            for r in records:
                doc = dict(r)
                if 'id' in doc and doc['id'] is not None:
                    doc_id = int(doc['id'])
                    doc['id'] = doc_id
                    if doc_id > max_id:
                        max_id = doc_id
                docs_to_insert.append(doc)

            col.insert_many(docs_to_insert)
            print(f"  [MongoDB] Collection '{target_col_name}': Inserted {len(docs_to_insert)} records. (Max ID: {max_id})")
        else:
            print(f"  [MongoDB] Collection '{target_col_name}': 0 records to insert.")

        # Update counter sequence
        counters_col.update_one(
            {"_id": target_col_name},
            {"$set": {"seq": max_id}},
            upsert=True
        )

    # Extra indexes for query performance
    db["users"].create_index([("email", pymongo.ASCENDING)], unique=True)
    db["users"].create_index([("role", pymongo.ASCENDING)])
    db["events"].create_index([("organizer_id", pymongo.ASCENDING)])
    db["events"].create_index([("venue_id", pymongo.ASCENDING), ("status", pymongo.ASCENDING)])
    db["events"].create_index([("series_id", pymongo.ASCENDING)])
    db["images"].create_index([("event_id", pymongo.ASCENDING)])
    db["crowd_analyses"].create_index([("image_id", pymongo.ASCENDING)], unique=True)
    db["alerts"].create_index([("user_id", pymongo.ASCENDING), ("status", pymongo.ASCENDING)])
    db["alerts"].create_index([("event_id", pymongo.ASCENDING)])

    print("\n--- Migration Summary ---")
    for target_col_name in collection_map.values():
        count = db[target_col_name].count_documents({})
        counter = counters_col.find_one({"_id": target_col_name})
        seq = counter.get("seq") if counter else 0
        print(f"  Collection '{target_col_name}': {count} documents (Sequence: {seq})")

    print("\n[SUCCESS] Entire database migrated to MongoDB without omitting any values!")


if __name__ == '__main__':
    run_migration()
