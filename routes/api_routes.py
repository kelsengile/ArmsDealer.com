# ──────────────────────────────────────────────────────────────────────────────────
# API ROUTES
# ──────────────────────────────────────────────────────────────────────────────────
from flask import Blueprint, request, jsonify, render_template
from db_helpers import get_db, get_locale, get_currency

api_bp = Blueprint('api', __name__)


# ─────────────────────────────────────────
# PRODUCT & SERVICE LISTING API
# ─────────────────────────────────────────

@api_bp.route('/api/products/<category_slug>')
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


@api_bp.route('/api/services/<category_slug>')
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


@api_bp.route('/api/brands/<brand_slug>')
def api_products_by_brand(brand_slug):
    """Return all products for a given brand slug filtered by access level.
    Query params:
        access   = authorized | restricted  (default: authorized)
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
        JOIN brands b ON b.id = p.brand_id
        LEFT JOIN subcategories sc ON sc.id = p.subcategory_id
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE b.slug = ?
          AND p.is_authorized = ?
        ORDER BY p.id
    """, (lang, brand_slug, is_authorized)).fetchall()

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

@api_bp.route('/product/<slug>')
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
        LEFT JOIN categories c     ON c.id = p.category_id
        LEFT JOIN subcategories sc ON sc.id = p.subcategory_id
        LEFT JOIN brands b         ON b.id = p.brand_id
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE p.slug = ?
    """, (lang, slug)).fetchone()

    if not product:
        return "Product not found", 404

    # ── Additional product images (for the 5-slot gallery) ──────────────
    product_images = db.execute("""
        SELECT image_file, sort_order
        FROM product_images
        WHERE product_id = ?
        ORDER BY sort_order ASC
        LIMIT 4
    """, (product['id'],)).fetchall()

    # ── Brand product count ──────────────────────────────────────────────
    brand_product_count = 0
    if product['brand_id']:
        row = db.execute(
            "SELECT COUNT(*) AS cnt FROM products WHERE brand_id = ?",
            (product['brand_id'],)
        ).fetchone()
        brand_product_count = row['cnt'] if row else 0

    # ── Related products — same subcategory, same access, different slug ─
    related = db.execute("""
        SELECT p.id, p.slug, p.price, p.discount, p.image_file,
               p.rating, p.sales_count,
               COALESCE(pt.name, p.name) AS name
        FROM products p
        LEFT JOIN products_translations pt
               ON pt.product_id = p.id AND pt.lang_code = ?
        WHERE p.subcategory_id = (
                SELECT subcategory_id FROM products WHERE slug = ?
              )
          AND p.slug          != ?
          AND p.is_authorized  = (
                SELECT is_authorized FROM products WHERE slug = ?
              )
        ORDER BY p.sales_count DESC
        LIMIT 6
    """, (lang, slug, slug, slug)).fetchall()

    return render_template(
        'specific/specificproduct.html',
        product=product,
        product_images=product_images,
        brand_product_count=brand_product_count,
        related=related,
        currency=currency
    )
