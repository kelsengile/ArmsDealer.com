"""
auth_routes.py — ArmsDealer
Login, register, and logout routes.
Populates session with all fields the account panel needs.
"""

import sqlite3
from functools import wraps
from flask import (
    Blueprint, render_template, request,
    redirect, url_for, session, flash, g
)
from werkzeug.security import generate_password_hash, check_password_hash

auth_bp = Blueprint('auth', __name__)

DATABASE = 'armsdealerdb.sqlite'   # adjust path to match your app


def get_db():
    """Return a database connection, reusing g._database within a request."""
    db = getattr(g, '_database', None)
    if db is None:
        db = g._database = sqlite3.connect(DATABASE)
        db.row_factory = sqlite3.Row
    return db


def login_required(f):
    """Decorator — redirect to login if user is not in session."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('user_id'):
            flash('Please log in to access that page.', 'warning')
            return redirect(url_for('auth.login'))
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    """Decorator — redirect if user is not admin."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get('role') != 'admin':
            flash('Admin access required.', 'danger')
            return redirect(url_for('homepage'))
        return f(*args, **kwargs)
    return decorated


def _populate_session(user):
    """Write user fields into the Flask session."""
    session.permanent = True
    session['user_id'] = user['id']
    session['username'] = user['username']
    session['email'] = user['email']
    session['role'] = user['role']
    session['created_at'] = user['created_at']
    # cart_count: update this whenever cart changes;
    # here we just initialise to 0 if not already set
    if 'cart_count' not in session:
        session['cart_count'] = 0


# ─── LOGIN ────────────────────────────────────────────────────────
@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    # Already logged in — go home
    if session.get('user_id'):
        return redirect(url_for('homepage'))

    if request.method == 'POST':
        identifier = request.form.get(
            'identifier', '').strip()  # username OR email
        password = request.form.get('password', '')

        if not identifier or not password:
            flash('Please fill in all fields.', 'danger')
            return render_template('auth/login.html')

        db = get_db()
        user = db.execute(
            'SELECT * FROM users WHERE username = ? OR email = ?',
            (identifier, identifier)
        ).fetchone()

        if user is None or not check_password_hash(user['password_hash'], password):
            flash('Invalid credentials. Try again.', 'danger')
            return render_template('auth/login.html')

        _populate_session(user)
        flash(f'Welcome back, {user["username"]}.', 'success')
        return redirect(request.args.get('next') or url_for('homepage'))

    return render_template('auth/login.html')


# ─── REGISTER ─────────────────────────────────────────────────────
@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if session.get('user_id'):
        return redirect(url_for('homepage'))

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password', '')
        confirm = request.form.get('confirm_password', '')

        # Basic validation
        errors = []
        if not username or not email or not password:
            errors.append('All fields are required.')
        if password != confirm:
            errors.append('Passwords do not match.')
        if len(password) < 8:
            errors.append('Password must be at least 8 characters.')

        if errors:
            for e in errors:
                flash(e, 'danger')
            return render_template('auth/register.html')

        db = get_db()

        # Check uniqueness
        existing = db.execute(
            'SELECT id FROM users WHERE username = ? OR email = ?',
            (username, email)
        ).fetchone()

        if existing:
            flash('Username or email already taken.', 'danger')
            return render_template('auth/register.html')

        pw_hash = generate_password_hash(password)
        db.execute(
            'INSERT INTO users (username, email, password_hash, role) VALUES (?, ?, ?, ?)',
            (username, email, pw_hash, 'customer')
        )
        db.commit()

        user = db.execute(
            'SELECT * FROM users WHERE username = ?', (username,)
        ).fetchone()

        _populate_session(user)
        flash(f'Account created. Welcome, {username}!', 'success')
        return redirect(url_for('homepage'))

    return render_template('auth/register.html')


# ─── LOGOUT ───────────────────────────────────────────────────────
@auth_bp.route('/logout')
def logout():
    username = session.get('username', 'Operator')
    session.clear()
    flash(f'Session terminated. Goodbye, {username}.', 'info')
    return redirect(url_for('homepage'))
