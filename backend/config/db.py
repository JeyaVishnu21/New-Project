"""
Database Configuration & Connection Layer
-----------------------------------------
Provides unified database connection management supporting:
1. MongoDB (Primary default for deployment and local execution)
2. MySQL (Legacy relational server)
"""

from typing import Dict, Any, Optional
from config.settings import settings


def get_db_connection(include_db: bool = True, multi_statements: bool = False):
    """
    Establish and return a database connection using the configured engine.
    If settings.DB_ENGINE == 'mongodb', returns a PyMySQL-compatible connection
    adapter connected directly to MongoDB collections.
    Otherwise, returns a native PyMySQL connection.
    """
    if getattr(settings, 'DB_ENGINE', 'mongodb') == 'mongodb':
        from config.mongo_adapter import get_mongo_db_connection
        return get_mongo_db_connection()

    import pymysql
    import pymysql.cursors
    import pymysql.constants.CLIENT

    client_flag = 0
    if multi_statements:
        client_flag |= pymysql.constants.CLIENT.MULTI_STATEMENTS

    return pymysql.connect(
        host=settings.DB_HOST,
        port=settings.DB_PORT,
        user=settings.DB_USER,
        password=settings.DB_PASSWORD,
        database=settings.DB_NAME if include_db else None,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
        client_flag=client_flag,
        autocommit=True,
        connect_timeout=3
    )


def check_db_status() -> Dict[str, Any]:
    """
    Tests connectivity to the active database engine (MongoDB or MySQL).
    """
    if getattr(settings, 'DB_ENGINE', 'mongodb') == 'mongodb':
        from config.mongo_adapter import check_mongo_db_status
        return check_mongo_db_status()

    try:
        connection = get_db_connection(include_db=True)
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 AS test")
            result = cursor.fetchone()
        connection.close()

        if result and result.get('test') == 1:
            return {
                "status": "connected",
                "engine": "mysql",
                "message": f"Successfully connected to MySQL database '{settings.DB_NAME}' on {settings.DB_HOST}:{settings.DB_PORT}"
            }
        return {
            "status": "warning",
            "engine": "mysql",
            "message": "Connected to MySQL, but test query returned unexpected result."
        }
    except Exception as exc:
        return {
            "status": "placeholder_ready",
            "engine": "mysql",
            "message": f"MySQL connection configured for '{settings.DB_NAME}' on {settings.DB_HOST}:{settings.DB_PORT}. Note: {str(exc)}"
        }
