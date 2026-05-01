# ──────────────────────────────────────────────────────────────────────────────────
# DB_HELPERS.PY
# Shared database and locale utilities imported by all route blueprints.
# Lives at the project root so it can be imported without circular dependencies.
# ──────────────────────────────────────────────────────────────────────────────────
import sqlite3
import os
from flask import g, request

DATABASE = os.path.join(os.path.dirname(__file__), 'database', 'armsdealer.db')


def get_db():
    """Open a database connection if none exists for the current request."""
    if 'db' not in g:
        g.db = sqlite3.connect(DATABASE)
        g.db.row_factory = sqlite3.Row
    return g.db


def get_locale():
    return request.cookies.get('lang', 'english')


def get_currency(db):
    code = request.cookies.get('currency', 'PHP')
    currency = db.execute(
        "SELECT * FROM currencies WHERE code = ?", (code,)
    ).fetchone()
    return currency or db.execute(
        "SELECT * FROM currencies WHERE code = 'PHP'"
    ).fetchone()
