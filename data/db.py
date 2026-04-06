import sqlite3
import os

DATABASE = os.path.join(os.path.dirname(__file__), 'armsdealer.db')
SCHEMA = os.path.join(os.path.dirname(__file__), 'schema.sql')


def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    db = get_db()
    with open(SCHEMA, 'r') as f:
        db.executescript(f.read())
    db.commit()
    db.close()
    print("Database initialized.")
