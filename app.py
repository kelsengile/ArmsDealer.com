# ──────────────────────────────────────────────────────────────────────────────────
# APP.PY
# ──────────────────────────────────────────────────────────────────────────────────

import json as _json
from flask import Flask, render_template, redirect, url_for, request, session, flash, g, jsonify
import sqlite3
import os
from dotenv import load_dotenv
from routes.auth_routes import auth_bp
load_dotenv()

app = Flask(__name__)
app.register_blueprint(auth_bp)

# ── Custom Jinja2 filter: parse a JSON string inside templates ──


@app.template_filter('from_json')
def from_json_filter(value):
    try:
        return _json.loads(value)
    except Exception:
        return []


app.secret_key = os.environ.get(
    'SECRET_KEY', 'dev-secret-change-in-production')
DATABASE = os.path.join(os.path.dirname(__file__), 'database', 'armsdealer.db')
# ─────────────────────────────────────────
# DATABASE HELPERS
# ─────────────────────────────────────────


def get_db():
    """Open a database connection if none exists for the current request."""
    if 'db' not in g:
        g.db = sqlite3.connect(DATABASE)
        g.db.row_factory = sqlite3.Row
    return g.db


@app.teardown_appcontext
def close_db(error):
    """Close the database connection at the end of the request."""
    db = g.pop('db', None)
    if db is not None:
        db.close()


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
# ─────────────────────────────────────────
# MAIN ROUTES
# ─────────────────────────────────────────


@app.route('/')
@app.route('/home')
def homepage():
    db = get_db()
    lang = get_locale()
    currency = get_currency(db)
    product_rows = db.execute("""
    SELECT p.id, p.price, p.discount, p.image_file, p.tags,
           COALESCE(pt.name, p.name)               AS name,
           COALESCE(pt.description, p.description) AS description
    FROM products p
    LEFT JOIN products_translations pt
           ON pt.product_id = p.id AND pt.lang_code = ?
    WHERE p.id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    ORDER BY p.id
""", (lang,)).fetchall()
    products = {row["id"]: row for row in product_rows}
    service_rows = db.execute("""
    SELECT s.id, s.price, s.discount, s.image_file, s.tags,
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


@app.route('/products')
def products():
    return render_template('products.html')


@app.route('/services')
def services():
    return render_template('services.html')


@app.route('/about')
def about():
    return render_template('about.html')


@app.route('/contacts')
def contacts():
    return render_template('contacts.html')


@app.route('/legal')
def legal():
    return render_template('legal.html')


@app.route('/settings')
def settings():
    return render_template('settings.html')
# ─────────────────────────────────────────
# CART & CHECKOUT ROUTES
# ─────────────────────────────────────────


@app.route('/cart')
def cart():
    return render_template('user/cart.html')


@app.route('/checkout')
def checkout():
    return render_template('user/checkout.html')


# ─────────────────────────────────────────
# API ROUTES
# ─────────────────────────────────────────

@app.route('/api/products/<category_slug>')
def api_products_by_category(category_slug):
    """Return all products for a given category slug filtered by access level.
    Query params:
        access   = authorized | restricted  (default: authorized)
        currency = PHP | USD | EUR | ...    (falls back to cookie)
    """
    db = get_db()
    lang = get_locale()
    currency = get_currency(db)
    access = request.args.get('access', 'authorized')
    is_authorized = 1 if access == 'authorized' else 0

    rows = db.execute("""
        SELECT p.id, p.slug, p.price, p.discount, p.image_file, p.tags,
               p.is_authorized, p.rating, p.sales_count,
               p.subcategory_id,
               sc.slug AS subcategory_slug,
               COALESCE(pt.name, p.name)               AS name,
               COALESCE(pt.description, p.description) AS description
        FROM products p
        JOIN categories c ON c.id = p.category_id
        LEFT JOIN subcategories sc ON sc.id = p.subcategory_id
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE c.slug = ?
          AND p.is_authorized = ?
        ORDER BY p.id
    """, (lang, category_slug, is_authorized)).fetchall()

    result = []
    for r in rows:
        discounted = r['price'] - (r['price'] * (r['discount'] / 100))
        result.append({
            'id':               r['id'],
            'slug':             r['slug'],
            'name':             r['name'],
            'description':      r['description'],
            'price':            r['price'],
            'discount':         r['discount'],
            'image_file':       r['image_file'] or '',
            'tags':             r['tags'] or '[]',
            'is_authorized':    r['is_authorized'],
            'rating':           r['rating'],
            'sales_count':      r['sales_count'],
            'subcategory_slug': r['subcategory_slug'] or '',
            'currency_symbol':  currency['symbol'],
            'currency_rate':    currency['rate_to_php'],
            'old_price':        round(r['price'] * currency['rate_to_php']),
            'new_price':        round(discounted * currency['rate_to_php']),
        })
    return jsonify(products=result)


@app.route('/api/services/<category_slug>')
def api_services_by_category(category_slug):
    """Return all services for a given category slug."""
    db = get_db()
    lang = get_locale()
    currency = get_currency(db)
    access = request.args.get('access', 'authorized')
    is_authorized = 1 if access == 'authorized' else 0

    rows = db.execute("""
        SELECT s.id, s.slug, s.price, s.discount, s.image_file, s.tags,
               s.is_authorized, s.rating, s.sales_count,
               s.subcategory_id,
               sc.slug AS subcategory_slug,
               COALESCE(st.name, s.name)               AS name,
               COALESCE(st.description, s.description) AS description
        FROM services s
        JOIN categories c ON c.id = s.category_id
        LEFT JOIN subcategories sc ON sc.id = s.subcategory_id
        LEFT JOIN services_translations st
               ON st.service_id = s.id AND st.lang_code = ?
        WHERE c.slug = ?
          AND s.is_authorized = ?
        ORDER BY s.id
    """, (lang, category_slug, is_authorized)).fetchall()

    result = []
    for r in rows:
        discounted = r['price'] - (r['price'] * (r['discount'] / 100))
        result.append({
            'id':               r['id'],
            'slug':             r['slug'],
            'name':             r['name'],
            'description':      r['description'],
            'price':            r['price'],
            'discount':         r['discount'],
            'image_file':       r['image_file'] or '',
            'tags':             r['tags'] or '[]',
            'is_authorized':    r['is_authorized'],
            'rating':           r['rating'],
            'sales_count':      r['sales_count'],
            'subcategory_slug': r['subcategory_slug'] or '',
            'currency_symbol':  currency['symbol'],
            'currency_rate':    currency['rate_to_php'],
            'old_price':        round(r['price'] * currency['rate_to_php']),
            'new_price':        round(discounted * currency['rate_to_php']),
        })
    return jsonify(products=result)


# ─────────────────────────────────────────
# PRODUCT DETAIL ROUTE
# ─────────────────────────────────────────

@app.route('/product/<slug>')
def product_detail(slug):
    db = get_db()
    lang = get_locale()
    currency = get_currency(db)

    product = db.execute("""
        SELECT p.id, p.slug, p.price, p.discount, p.image_file, p.tags,
               p.is_authorized, p.rating, p.sales_count, p.stock,
               p.brand_id,
               b.name AS brand_name, b.slug AS brand_slug, b.logo_file,
               c.slug AS category_slug, c.name AS category_name,
               sc.slug AS subcategory_slug, sc.name AS subcategory_name,
               COALESCE(pt.name, p.name)               AS name,
               COALESCE(pt.description, p.description) AS description
        FROM products p
        LEFT JOIN categories c   ON c.id = p.category_id
        LEFT JOIN subcategories sc ON sc.id = p.subcategory_id
        LEFT JOIN brands b       ON b.id = p.brand_id
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE p.slug = ?
    """, (lang, slug)).fetchone()

    if not product:
        return "Product not found", 404

    # Related products — same subcategory, same access level, different slug
    related = db.execute("""
        SELECT p.id, p.slug, p.price, p.discount, p.image_file,
               COALESCE(pt.name, p.name) AS name
        FROM products p
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE p.subcategory_id = (
                SELECT subcategory_id FROM products WHERE slug = ?
              )
          AND p.slug      != ?
          AND p.is_authorized = (
                SELECT is_authorized FROM products WHERE slug = ?
              )
        ORDER BY p.sales_count DESC
        LIMIT 6
    """, (lang, slug, slug, slug)).fetchall()

    return render_template(
        '/templates/specific/specificproduct.html',
        product=product,
        related=related,
        currency=currency
    )


# ─────────────────────────────────────────
# RUN
# ─────────────────────────────────────────
if __name__ == '__main__':
    app.run(debug=True)
