-- ============================================================
--  ArmsDealer.com - Database Schema
-- ============================================================

-- ------------------------------------------------------------
-- ACCOUNTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS accounts (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    username            TEXT NOT NULL UNIQUE,
    email               TEXT NOT NULL UNIQUE,
    password_hash       TEXT NOT NULL,
    account_type        TEXT NOT NULL CHECK(account_type IN ('User', 'Admin', 'Developer')),
    first_name          TEXT,
    last_name           TEXT,
    phone               TEXT,
    avatar_url          TEXT,
    is_active           INTEGER NOT NULL DEFAULT 1,
    is_verified         INTEGER NOT NULL DEFAULT 0,
    two_factor_enabled  INTEGER NOT NULL DEFAULT 0,
    two_factor_secret   TEXT,
    last_login          TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS account_permissions (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER NOT NULL UNIQUE,
    can_purchase        INTEGER DEFAULT 1,
    can_review          INTEGER DEFAULT 1,
    can_wishlist        INTEGER DEFAULT 1,
    can_manage_products INTEGER DEFAULT 0,
    can_manage_orders   INTEGER DEFAULT 0,
    can_manage_users    INTEGER DEFAULT 0,
    can_view_reports    INTEGER DEFAULT 0,
    can_manage_admins   INTEGER DEFAULT 0,
    can_access_api      INTEGER DEFAULT 0,
    can_modify_schema   INTEGER DEFAULT 0,
    can_view_logs       INTEGER DEFAULT 0,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS addresses (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER NOT NULL,
    label               TEXT DEFAULT 'Home',
    full_name           TEXT NOT NULL,
    phone               TEXT,
    address_line1       TEXT NOT NULL,
    address_line2       TEXT,
    city                TEXT NOT NULL,
    state               TEXT,
    postal_code         TEXT NOT NULL,
    country             TEXT NOT NULL,
    is_default          INTEGER DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);


-- ------------------------------------------------------------
-- PRODUCTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS products (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    name                TEXT NOT NULL,
    slug                TEXT NOT NULL UNIQUE,
    sku                 TEXT UNIQUE,
    description         TEXT,
    short_description   TEXT,
    price               REAL NOT NULL CHECK(price >= 0),
    discount_percent    REAL DEFAULT 0 CHECK(discount_percent BETWEEN 0 AND 100),
    stock_quantity      INTEGER NOT NULL DEFAULT 0,
    weight_kg           REAL,
    dimensions          TEXT,
    image_url           TEXT,
    gallery             TEXT,
    item_type           TEXT NOT NULL CHECK(item_type IN ('Weapon', 'Equipment')),
    weapon_category     TEXT CHECK(weapon_category IN (
                            'Firearms','Blades','Blunts','Projectile',
                            'Explosives','Electronic','Chemical',
                            'Biological','Vehicle','Cyber','Security'
                        )),
    equipment_category  TEXT CHECK(equipment_category IN (
                            'Ammunition','Protective','Tactical','Attachments',
                            'Maintenance','Storage','Cases','Communication',
                            'Survival','Training'
                        )),
    brand               TEXT,
    origin_country      TEXT,
    condition           TEXT DEFAULT 'New' CHECK(condition IN ('New','Used','Refurbished')),
    is_active           INTEGER DEFAULT 1,
    is_featured         INTEGER DEFAULT 0,
    is_restricted       INTEGER DEFAULT 0,
    created_by          INTEGER,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES accounts(id)
);


-- ------------------------------------------------------------
-- SERVICES
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS services (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    name                TEXT NOT NULL,
    slug                TEXT NOT NULL UNIQUE,
    description         TEXT,
    short_description   TEXT,
    price               REAL CHECK(price >= 0),
    price_type          TEXT DEFAULT 'Fixed' CHECK(price_type IN ('Fixed','Hourly','Quote')),
    discount_percent    REAL DEFAULT 0 CHECK(discount_percent BETWEEN 0 AND 100),
    service_category    TEXT NOT NULL CHECK(service_category IN (
                            'Manufacturing','Customization','Maintenance',
                            'Transport','Storage','Training','Protection',
                            'Consulting','Research','Testing','Disposal',
                            'Surveillance','Contracting'
                        )),
    duration_days       INTEGER,
    image_url           TEXT,
    gallery             TEXT,
    availability        TEXT DEFAULT 'Available' CHECK(availability IN ('Available','Unavailable','By Request')),
    is_active           INTEGER DEFAULT 1,
    is_featured         INTEGER DEFAULT 0,
    is_restricted       INTEGER DEFAULT 0,
    created_by          INTEGER,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES accounts(id)
);


-- ------------------------------------------------------------
-- CART
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cart (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER NOT NULL,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_items (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    cart_id             INTEGER NOT NULL,
    item_type           TEXT NOT NULL CHECK(item_type IN ('Product','Service')),
    product_id          INTEGER,
    service_id          INTEGER,
    quantity            INTEGER NOT NULL DEFAULT 1 CHECK(quantity > 0),
    unit_price          REAL NOT NULL,
    added_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id)    REFERENCES cart(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);


-- ------------------------------------------------------------
-- ORDERS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    order_number        TEXT NOT NULL UNIQUE,
    account_id          INTEGER NOT NULL,
    status              TEXT NOT NULL DEFAULT 'Pending' CHECK(status IN (
                            'Pending','Confirmed','Processing',
                            'Shipped','Delivered','Cancelled','Refunded'
                        )),
    subtotal            REAL NOT NULL,
    discount_total      REAL DEFAULT 0,
    tax_total           REAL DEFAULT 0,
    shipping_total      REAL DEFAULT 0,
    grand_total         REAL NOT NULL,
    shipping_address_id INTEGER,
    billing_address_id  INTEGER,
    coupon_id           INTEGER,
    notes               TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id)          REFERENCES accounts(id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(id),
    FOREIGN KEY (billing_address_id)  REFERENCES addresses(id),
    FOREIGN KEY (coupon_id)           REFERENCES coupons(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id            INTEGER NOT NULL,
    item_type           TEXT NOT NULL CHECK(item_type IN ('Product','Service')),
    product_id          INTEGER,
    service_id          INTEGER,
    quantity            INTEGER NOT NULL DEFAULT 1,
    unit_price          REAL NOT NULL,
    discount_applied    REAL DEFAULT 0,
    line_total          REAL NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);


-- ------------------------------------------------------------
-- PAYMENTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id            INTEGER NOT NULL,
    account_id          INTEGER NOT NULL,
    amount              REAL NOT NULL,
    currency            TEXT DEFAULT 'USD',
    method              TEXT CHECK(method IN ('Card','Bank Transfer','Crypto','Cash','Invoice')),
    status              TEXT DEFAULT 'Pending' CHECK(status IN ('Pending','Paid','Failed','Refunded')),
    transaction_ref     TEXT,
    paid_at             TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id)   REFERENCES orders(id),
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);


-- ------------------------------------------------------------
-- REVIEWS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reviews (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER NOT NULL,
    item_type           TEXT NOT NULL CHECK(item_type IN ('Product','Service')),
    product_id          INTEGER,
    service_id          INTEGER,
    rating              INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
    title               TEXT,
    body                TEXT,
    is_verified_purchase INTEGER DEFAULT 0,
    is_approved         INTEGER DEFAULT 0,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);


-- ------------------------------------------------------------
-- WISHLIST
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wishlist (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER NOT NULL,
    item_type           TEXT NOT NULL CHECK(item_type IN ('Product','Service')),
    product_id          INTEGER,
    service_id          INTEGER,
    added_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);


-- ------------------------------------------------------------
-- COUPONS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS coupons (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    code                TEXT NOT NULL UNIQUE,
    description         TEXT,
    discount_type       TEXT NOT NULL CHECK(discount_type IN ('Percent','Fixed')),
    discount_value      REAL NOT NULL,
    min_order_amount    REAL DEFAULT 0,
    max_uses            INTEGER,
    used_count          INTEGER DEFAULT 0,
    valid_from          TIMESTAMP,
    valid_until         TIMESTAMP,
    is_active           INTEGER DEFAULT 1,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ------------------------------------------------------------
-- ACTIVITY / AUDIT LOG
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS activity_log (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id          INTEGER,
    action              TEXT NOT NULL,
    target_type         TEXT,
    target_id           INTEGER,
    ip_address          TEXT,
    user_agent          TEXT,
    details             TEXT,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(id)
);
