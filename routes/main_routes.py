# ──────────────────────────────────────────────────────────────────────────────────
# MAIN ROUTES
# ──────────────────────────────────────────────────────────────────────────────────
from flask import Blueprint, render_template, request, g, session, redirect, url_for
from db_helpers import get_db, get_locale, get_currency

main_bp = Blueprint('main', __name__)


@main_bp.route('/')
@main_bp.route('/home')
def homepage():
    db = get_db()
    lang = get_locale()
    currency = get_currency(db)
    product_rows = db.execute("""
    SELECT p.id, p.slug, p.price, p.discount, p.image_file, p.tags,
           p.rating, p.sales_count,
           COALESCE(pt.name, p.name)               AS name,
           COALESCE(pt.description, p.description) AS description
    FROM products p
    LEFT JOIN products_translations pt
           ON pt.product_id = p.id AND pt.lang_code = ?
    WHERE p.id IN (1,5,6,7,8,19,21,62,161,162,163,164,165,302,319,318)
    ORDER BY p.id
""", (lang,)).fetchall()
    products = {row["id"]: row for row in product_rows}
    service_rows = db.execute("""
    SELECT s.id, s.slug, s.price, s.discount, s.image_file, s.tags,
           s.rating, s.sales_count,
           COALESCE(st.name, s.name)               AS name,
           COALESCE(st.description, s.description) AS description
    FROM services s
    LEFT JOIN services_translations st
           ON st.service_id = s.id AND st.lang_code = ?
    WHERE s.id IN (1,2,3)
    ORDER BY s.id
""", (lang,)).fetchall()
    services = {row["id"]: row for row in service_rows}
    return render_template('homepage.html', products=products, services=services, currency=currency)


@main_bp.route('/products')
def products():
    return render_template('products.html')


@main_bp.route('/services')
def services():
    return render_template('services.html')


@main_bp.route('/about')
def about():
    return render_template('about.html')


@main_bp.route('/contacts')
def contacts():
    return render_template('contacts.html')


@main_bp.route('/settings')
def settings():
    return render_template('settings.html')


@main_bp.route('/legal')
def legal():
    return render_template('legal.html')


# ─────────────────────────────────────────
# ACCOUNT PAGE
# ─────────────────────────────────────────

@main_bp.route('/account')
def account():
    """User account profile page. Requires login."""
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))

    db = get_db()
    user = db.execute(
        'SELECT * FROM users WHERE id = ?', (session['user_id'],)
    ).fetchone()

    if not user:
        session.clear()
        return redirect(url_for('auth.login'))

    return render_template('user/account.html', user=user)


# ─────────────────────────────────────────
# ORDERS PAGE
# ─────────────────────────────────────────

@main_bp.route('/orders')
def orders():
    """Orders, cart, and shipping page. Requires login."""
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))

    db = get_db()
    user_id = session['user_id']
    currency = get_currency(db)

    # Fetch cart items with product/service details
    cart_rows = db.execute("""
        SELECT
            ci.item_type,
            ci.item_id,
            ci.quantity,
            CASE
                WHEN ci.item_type = 'product' THEN p.name
                WHEN ci.item_type = 'service' THEN s.name
            END AS name,
            CASE
                WHEN ci.item_type = 'product' THEN p.price
                WHEN ci.item_type = 'service' THEN s.price
            END AS price,
            CASE
                WHEN ci.item_type = 'product' THEN p.image_file
                WHEN ci.item_type = 'service' THEN s.image_file
            END AS image_file
        FROM cart_items ci
        LEFT JOIN products p ON ci.item_type = 'product' AND ci.item_id = p.id
        LEFT JOIN services s ON ci.item_type = 'service' AND ci.item_id = s.id
        WHERE ci.user_id = ?
        ORDER BY ci.id DESC
    """, (user_id,)).fetchall()

    cart_items = [dict(row) for row in cart_rows]

    # Calculate total BEFORE currency conversion
    cart_total_php = sum(
        (item['price'] or 0) * item['quantity'] for item in cart_items
    )

    # Convert to selected currency
    rate = currency['rate_to_php'] if currency else 1
    for item in cart_items:
        item['price'] = round((item['price'] or 0) * rate)
    cart_total = round(cart_total_php * rate)

    # Order history
    orders_rows = db.execute(
        'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
        (user_id,)
    ).fetchall()

    return render_template(
        'user/orders.html',
        cart_items=cart_items,
        cart_total=cart_total,
        orders=orders_rows,
        currency=currency
    )


# ─────────────────────────────────────────
# ADMIN DASHBOARD
# ─────────────────────────────────────────

@main_bp.route('/dashboard')
def dashboard():
    """Admin dashboard. Requires admin role."""
    if not session.get('user_id'):
        return redirect(url_for('auth.login'))
    if session.get('role') != 'admin':
        return redirect(url_for('main.homepage'))
    return render_template('user/dashboard.html')
