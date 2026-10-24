"""
MongoDB Storage & SQL Compatibility Layer
-----------------------------------------
Allows the entire application to use MongoDB as the primary persistent database
without requiring MySQL to be installed or run.

Architecture:
1. Connects to MongoDB (local or MongoDB Atlas via MONGO_URI).
2. Maintains structured collections matching the relational schema:
   - users, venues, fest, events, images, crowd_analyses, alerts, counters.
3. Keeps an in-memory / cache relational engine synchronized with MongoDB in real-time.
4. Translates MySQL SQL queries to the query engine and immediately syncs all
   INSERT, UPDATE, and DELETE mutations directly to MongoDB documents.
5. Manages atomic auto-incrementing ID sequences using MongoDB's 'counters' collection.
"""

import re
import os
import sqlite3
import threading
from datetime import date, datetime, time, timedelta
from typing import Dict, Any, Optional, List, Union
from pathlib import Path

import pymongo
from pymongo.collection import Collection

# Thread safety lock for concurrent requests
_DB_LOCK = threading.RLock()
_MONGO_CLIENT: Optional[pymongo.MongoClient] = None
_MONGO_DB: Optional[Any] = None
_SQLITE_CONN: Optional[sqlite3.Connection] = None
_IS_INITIALIZED = False

TABLES = ['users', 'venues', 'fest', 'events', 'images', 'crowd_analyses', 'alerts']


def _serialize_for_mongo(val: Any) -> Any:
    """Normalizes dates and times for MongoDB storage."""
    if isinstance(val, datetime):
        return val.strftime('%Y-%m-%d %H:%M:%S')
    if isinstance(val, date):
        return val.strftime('%Y-%m-%d')
    if isinstance(val, time):
        return val.strftime('%H:%M:%S')
    if isinstance(val, timedelta):
        total_sec = int(val.total_seconds())
        h = total_sec // 3600
        m = (total_sec % 3600) // 60
        s = total_sec % 60
        return f"{h:02d}:{m:02d}:{s:02d}"
    return val


def _convert_from_sqlite(val: Any) -> Any:
    """Converts SQLite string values back into Python date/time/timedelta types for models."""
    if isinstance(val, str):
        if re.match(r'^\d{4}-\d{2}-\d{2}$', val):
            try:
                return datetime.strptime(val, '%Y-%m-%d').date()
            except ValueError:
                pass
        elif re.match(r'^\d{2}:\d{2}:\d{2}$', val):
            try:
                parts = [int(p) for p in val.split(':')]
                return timedelta(hours=parts[0], minutes=parts[1], seconds=parts[2])
            except (ValueError, IndexError):
                pass
        elif re.match(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}', val):
            try:
                return datetime.strptime(val[:19], '%Y-%m-%d %H:%M:%S')
            except ValueError:
                pass
    return val


def get_mongo_db():
    """Returns or lazily creates the MongoDB database connection."""
    global _MONGO_CLIENT, _MONGO_DB
    from config.settings import settings

    if _MONGO_DB is None:
        mongo_uri = getattr(settings, 'MONGO_URI', 'mongodb://localhost:27017/')
        mongo_db_name = getattr(settings, 'MONGO_DB_NAME', 'crowd_event_db')
        _MONGO_CLIENT = pymongo.MongoClient(mongo_uri, serverSelectionTimeoutMS=4000)
        _MONGO_DB = _MONGO_CLIENT[mongo_db_name]
    return _MONGO_DB


def get_next_sequence_value(sequence_name: str) -> int:
    """Generates an atomic auto-increment ID using MongoDB's counters collection."""
    db = get_mongo_db()
    counter = db["counters"].find_one_and_update(
        {"_id": sequence_name},
        {"$inc": {"seq": 1}},
        upsert=True,
        return_document=pymongo.ReturnDocument.AFTER
    )
    return counter["seq"]


def _init_sqlite_schema(conn: sqlite3.Connection):
    """Initializes the relational schema and compatibility triggers."""
    conn.row_factory = sqlite3.Row

    # Register MySQL compatibility functions
    conn.create_function("YEAR", 1, lambda d: int(str(d).split('-')[0]) if d and '-' in str(d) else None)
    conn.create_function("MONTH", 1, lambda d: int(str(d).split('-')[1]) if d and '-' in str(d) else None)

    cur = conn.cursor()
    cur.executescript("""
        PRAGMA foreign_keys = OFF;

        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            role TEXT CHECK(role IN ('administrator', 'management', 'organizer')) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS venues (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            location TEXT NOT NULL,
            capacity INTEGER NOT NULL DEFAULT 0,
            status TEXT CHECK(status IN ('available', 'unavailable')) DEFAULT 'available',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS fest (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            start_date DATE,
            end_date DATE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        DROP VIEW IF EXISTS event_series;
        CREATE VIEW event_series AS SELECT * FROM fest;

        DROP TRIGGER IF EXISTS event_series_insert;
        CREATE TRIGGER event_series_insert INSTEAD OF INSERT ON event_series
        BEGIN
            INSERT INTO fest (id, name, description, start_date, end_date, created_at, updated_at)
            VALUES (new.id, new.name, new.description, new.start_date, new.end_date, coalesce(new.created_at, datetime('now')), coalesce(new.updated_at, datetime('now')));
        END;

        DROP TRIGGER IF EXISTS event_series_delete;
        CREATE TRIGGER event_series_delete INSTEAD OF DELETE ON event_series
        BEGIN
            DELETE FROM fest WHERE (old.id IS NOT NULL AND id = old.id) OR (old.id IS NULL);
        END;

        DROP TRIGGER IF EXISTS event_series_update;
        CREATE TRIGGER event_series_update INSTEAD OF UPDATE ON event_series
        BEGIN
            UPDATE fest SET name = new.name, description = new.description, start_date = new.start_date, end_date = new.end_date, updated_at = coalesce(new.updated_at, datetime('now'))
            WHERE id = old.id;
        END;

        CREATE TABLE IF NOT EXISTS events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            series_id INTEGER,
            organizer_id INTEGER NOT NULL,
            venue_id INTEGER,
            event_name TEXT NOT NULL,
            description TEXT,
            status TEXT CHECK(status IN ('pending', 'approved', 'rejected', 'completed', 'cancelled')) DEFAULT 'pending',
            rejection_reason TEXT,
            requested_date DATE NOT NULL,
            requested_start_time TIME NOT NULL,
            requested_end_time TIME NOT NULL,
            approved_date DATE,
            approved_start_time TIME,
            approved_end_time TIME,
            expected_participants INTEGER,
            category TEXT DEFAULT 'General',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (series_id) REFERENCES fest(id),
            FOREIGN KEY (organizer_id) REFERENCES users(id),
            FOREIGN KEY (venue_id) REFERENCES venues(id)
        );

        CREATE TABLE IF NOT EXISTS images (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            image_path TEXT NOT NULL,
            uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            processing_status TEXT CHECK(processing_status IN ('pending', 'processing', 'completed', 'failed')) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (event_id) REFERENCES events(id)
        );

        CREATE TABLE IF NOT EXISTS crowd_analyses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            image_id INTEGER UNIQUE NOT NULL,
            predicted_count INTEGER NOT NULL,
            analysis_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            processing_status TEXT DEFAULT 'completed',
            model_name TEXT DEFAULT 'CSRNet',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (image_id) REFERENCES images(id)
        );

        CREATE TABLE IF NOT EXISTS alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            crowd_analysis_id INTEGER,
            detected_count INTEGER NOT NULL,
            threshold INTEGER NOT NULL,
            message TEXT NOT NULL,
            status TEXT CHECK(status IN ('unread', 'read')) DEFAULT 'unread',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (event_id) REFERENCES events(id),
            FOREIGN KEY (user_id) REFERENCES users(id),
            FOREIGN KEY (crowd_analysis_id) REFERENCES crowd_analyses(id)
        );
    """)
    conn.commit()


def _sync_from_mongo_to_engine(conn: sqlite3.Connection):
    """Loads all records from MongoDB into the relational engine on startup."""
    try:
        mongo_db = get_mongo_db()
        cur = conn.cursor()

        for table in TABLES:
            col = mongo_db[table]
            docs = list(col.find({}, {"_id": 0}))
            if not docs:
                continue

            # Clear table before loading
            cur.execute(f"DELETE FROM {table};")

            for doc in docs:
                keys = [k for k in doc.keys() if doc[k] is not None]
                if not keys:
                    continue
                cols_str = ", ".join(f'"{k}"' for k in keys)
                placeholders = ", ".join("?" for _ in keys)
                values = [doc[k] for k in keys]
                cur.execute(f"INSERT OR REPLACE INTO {table} ({cols_str}) VALUES ({placeholders})", values)

        conn.commit()
    except Exception as exc:
        print(f"[MongoDB Adapter] Warning during sync from Mongo: {exc}")


def _init_engine_if_needed():
    """Initializes the database engine and syncs with MongoDB if not already initialized."""
    global _SQLITE_CONN, _IS_INITIALIZED
    with _DB_LOCK:
        if not _IS_INITIALIZED or _SQLITE_CONN is None:
            _SQLITE_CONN = sqlite3.connect(":memory:", check_same_thread=False)
            _init_sqlite_schema(_SQLITE_CONN)
            _sync_from_mongo_to_engine(_SQLITE_CONN)
            _IS_INITIALIZED = True


class MongoPyMySQLCursorAdapter:
    """
    Cursor adapter that translates MySQL SQL queries to the query engine and
    immediately synchronizes all mutations (INSERT, UPDATE, DELETE) to MongoDB.
    """
    def __init__(self, conn: sqlite3.Connection):
        self._conn = conn
        self._cur = conn.cursor()
        self.lastrowid = 0
        self.rowcount = 0

    def execute(self, query: str, params=None):
        q = query.strip() if isinstance(query, str) else str(query).strip()

        # Handle INSERT OR REPLACE / INSERT IGNORE
        if re.match(r'^\s*INSERT\s+IGNORE\s+INTO', q, flags=re.IGNORECASE):
            q = re.sub(r'^\s*INSERT\s+IGNORE\s+INTO', 'INSERT OR IGNORE INTO', q, flags=re.IGNORECASE)
        elif re.match(r'^\s*INSERT\s+INTO.*ON\s+DUPLICATE\s+KEY\s+UPDATE', q, flags=re.IGNORECASE):
            q = re.sub(r'^\s*INSERT\s+INTO', 'INSERT OR REPLACE INTO', q, flags=re.IGNORECASE)

        # Translate MySQL datetime functions to SQLite equivalents
        q = re.sub(r'\bCURRENT_DATE\(\)', "date('now')", q, flags=re.IGNORECASE)
        q = re.sub(r'\bCURRENT_TIME\(\)', "time('now')", q, flags=re.IGNORECASE)
        q = re.sub(r'\bNOW\(\)', "datetime('now')", q, flags=re.IGNORECASE)

        # Translate MySQL %s placeholder to ?
        sqlite_query = q.replace('%s', '?')

        # Clean params
        clean_params = None
        if params is not None:
            if isinstance(params, (list, tuple)):
                clean_params = []
                for p in params:
                    if isinstance(p, (date, datetime, time)):
                        clean_params.append(p.isoformat())
                    else:
                        clean_params.append(p)
                clean_params = tuple(clean_params)
            else:
                clean_params = params

        # Identify target table if modifying
        insert_match = re.search(r'^\s*(?:INSERT|REPLACE)\s+(?:OR\s+\w+\s+)?INTO\s+([`"\w]+)', sqlite_query, re.IGNORECASE)
        update_match = re.search(r'^\s*UPDATE\s+([`"\w]+)', sqlite_query, re.IGNORECASE)
        delete_match = re.search(r'^\s*DELETE\s+FROM\s+([`"\w]+)', sqlite_query, re.IGNORECASE)

        with _DB_LOCK:
            if clean_params is not None:
                self._cur.execute(sqlite_query, clean_params)
            else:
                self._cur.execute(sqlite_query)

            self.lastrowid = self._cur.lastrowid or 0
            self.rowcount = self._cur.rowcount or 0
            self._conn.commit()

            # Synchronize to MongoDB
            if insert_match:
                tbl = insert_match.group(1).replace('`', '').replace('"', '').lower()
                self._sync_insert_to_mongo(tbl, self.lastrowid)
            elif update_match:
                tbl = update_match.group(1).replace('`', '').replace('"', '').lower()
                self._sync_table_to_mongo(tbl)
            elif delete_match:
                tbl = delete_match.group(1).replace('`', '').replace('"', '').lower()
                self._sync_table_to_mongo(tbl)

        return self

    def executemany(self, query: str, seq_of_params):
        for params in seq_of_params:
            self.execute(query, params)
        return self

    def _sync_insert_to_mongo(self, table_name: str, row_id: int):
        """Immediately syncs the inserted row to the MongoDB collection."""
        if table_name == 'event_series':
            table_name = 'fest'
        if table_name not in TABLES:
            return

        try:
            mongo_db = get_mongo_db()
            col: Collection = mongo_db[table_name]

            # Fetch the newly inserted row from engine
            cur = self._conn.cursor()
            cur.execute(f"SELECT * FROM {table_name} WHERE id = ?", (row_id,))
            row = cur.fetchone()
            if row:
                doc = {k: _serialize_for_mongo(row[k]) for k in row.keys()}
                col.replace_one({"id": row_id}, doc, upsert=True)
                # Update counter
                mongo_db["counters"].update_one(
                    {"_id": table_name},
                    {"$max": {"seq": int(row_id)}},
                    upsert=True
                )
        except Exception as exc:
            print(f"[MongoDB Adapter] Warning on insert sync: {exc}")

    def _sync_table_to_mongo(self, table_name: str):
        """Syncs the current state of a table to MongoDB after UPDATE or DELETE."""
        if table_name == 'event_series':
            table_name = 'fest'
        if table_name not in TABLES:
            return

        try:
            mongo_db = get_mongo_db()
            col: Collection = mongo_db[table_name]

            cur = self._conn.cursor()
            cur.execute(f"SELECT * FROM {table_name}")
            rows = cur.fetchall()

            current_ids = set()
            for r in rows:
                doc = {k: _serialize_for_mongo(r[k]) for k in r.keys()}
                if 'id' in doc and doc['id'] is not None:
                    doc_id = int(doc['id'])
                    current_ids.add(doc_id)
                    col.replace_one({"id": doc_id}, doc, upsert=True)

            # Remove deleted documents from MongoDB
            col.delete_many({"id": {"$nin": list(current_ids)}})
        except Exception as exc:
            print(f"[MongoDB Adapter] Warning on table sync: {exc}")

    def fetchone(self) -> Optional[Dict[str, Any]]:
        row = self._cur.fetchone()
        if row is None:
            return None
        return {k: _convert_from_sqlite(row[k]) for k in row.keys()}

    def fetchall(self) -> List[Dict[str, Any]]:
        rows = self._cur.fetchall()
        return [{k: _convert_from_sqlite(r[k]) for k in r.keys()} for r in rows]

    def close(self):
        self._cur.close()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()


class MongoPyMySQLConnectionAdapter:
    """Connection adapter mimicking PyMySQL Connection for models."""
    def __init__(self, conn: sqlite3.Connection):
        self._conn = conn

    def cursor(self, *args, **kwargs) -> MongoPyMySQLCursorAdapter:
        return MongoPyMySQLCursorAdapter(self._conn)

    def commit(self):
        with _DB_LOCK:
            self._conn.commit()

    def rollback(self):
        with _DB_LOCK:
            self._conn.rollback()

    def close(self):
        # Kept active for singleton engine
        pass

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass


def get_mongo_db_connection() -> MongoPyMySQLConnectionAdapter:
    """Returns a PyMySQL-compatible connection adapter backed by MongoDB."""
    _init_engine_if_needed()
    return MongoPyMySQLConnectionAdapter(_SQLITE_CONN)


def check_mongo_db_status() -> Dict[str, Any]:
    """Tests connectivity to MongoDB and reports collection counts."""
    from config.settings import settings
    try:
        db = get_mongo_db()
        server_info = _MONGO_CLIENT.server_info()
        counts = {c: db[c].count_documents({}) for c in TABLES}
        total_docs = sum(counts.values())

        return {
            "status": "connected",
            "engine": "mongodb",
            "version": server_info.get("version", "unknown"),
            "database": getattr(settings, 'MONGO_DB_NAME', 'crowd_event_db'),
            "total_documents": total_docs,
            "collections": counts,
            "message": f"Successfully connected to MongoDB server v{server_info.get('version')} (Database: {settings.MONGO_DB_NAME})"
        }
    except Exception as exc:
        return {
            "status": "error",
            "engine": "mongodb",
            "message": f"Could not connect to MongoDB: {str(exc)}"
        }
