PRAGMA foreign_keys = ON;

-- ─────────────────────────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    email         TEXT    NOT NULL UNIQUE,
    password_hash TEXT    NOT NULL,
    role          TEXT    NOT NULL DEFAULT 'customer',   -- 'customer' | 'admin'
    created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ─────────────────────────────────────────────────────────────────
-- LANGUAGES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS languages (
    code        TEXT    PRIMARY KEY,
    label       TEXT    NOT NULL,
    locale      TEXT    NOT NULL,
    is_active   INTEGER NOT NULL DEFAULT 1,
    sort_order  INTEGER NOT NULL DEFAULT 0
);

-- ─────────────────────────────────────────────────────────────────
-- CURRENCIES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS currencies (
    code        TEXT    PRIMARY KEY,
    symbol      TEXT    NOT NULL,
    label       TEXT    NOT NULL,
    rate_to_php REAL    NOT NULL DEFAULT 1.0,
    is_active   INTEGER NOT NULL DEFAULT 1,
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ─────────────────────────────────────────────────────────────────
-- BRANDS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS brands (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    slug        TEXT    NOT NULL UNIQUE,
    logo_file   TEXT,
    description TEXT,
    is_active   INTEGER NOT NULL DEFAULT 1,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS brands_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id    INTEGER NOT NULL,
    lang_code   TEXT    NOT NULL,
    name        TEXT    NOT NULL,
    description TEXT,
    UNIQUE (brand_id, lang_code),
    FOREIGN KEY (brand_id)   REFERENCES brands(id)    ON DELETE CASCADE,
    FOREIGN KEY (lang_code)  REFERENCES languages(code)
);

-- ─────────────────────────────────────────────────────────────────
-- CATEGORIES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    slug        TEXT    NOT NULL UNIQUE,
    type        TEXT    NOT NULL DEFAULT 'product',     -- 'product' | 'service'
    icon_file   TEXT,
    description TEXT
);

CREATE TABLE IF NOT EXISTS category_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    UNIQUE (category_id, lang_code)
);

-- ─────────────────────────────────────────────────────────────────
-- SUBCATEGORIES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS subcategories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name        TEXT    NOT NULL,
    slug        TEXT    NOT NULL UNIQUE,
    icon_file   TEXT,
    description TEXT,
    UNIQUE (category_id, name)
);

CREATE TABLE IF NOT EXISTS subcategory_translations (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    subcategory_id INTEGER NOT NULL REFERENCES subcategories(id) ON DELETE CASCADE,
    lang_code      TEXT    NOT NULL REFERENCES languages(code),
    name           TEXT    NOT NULL,
    description    TEXT,
    UNIQUE (subcategory_id, lang_code)
);

-- ─────────────────────────────────────────────────────────────────
-- PRODUCTS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    name           TEXT    NOT NULL,
    slug           TEXT    NOT NULL UNIQUE,
    category_id    INTEGER NOT NULL REFERENCES categories(id),
    subcategory_id INTEGER REFERENCES subcategories(id),
    brand_id       INTEGER REFERENCES brands(id),
    description    TEXT,
    price          REAL    NOT NULL,
    discount       REAL    DEFAULT 0,
    stock          INTEGER NOT NULL DEFAULT 0,
    rating         REAL    NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count    INTEGER NOT NULL DEFAULT 0,
    image_file     TEXT,
    tags           TEXT,                                -- JSON array string
    is_featured    INTEGER NOT NULL DEFAULT 0,
    created_at     TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at     TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS products_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    tags        TEXT,
    UNIQUE (product_id, lang_code)
);

-- ─────────────────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS services (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    name           TEXT    NOT NULL,
    slug           TEXT    NOT NULL UNIQUE,
    category_id    INTEGER NOT NULL REFERENCES categories(id),
    subcategory_id INTEGER REFERENCES subcategories(id),
    brand_id       INTEGER REFERENCES brands(id),
    description    TEXT,
    price          REAL    NOT NULL,
    discount       REAL    DEFAULT 0,
    rating         REAL    NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count    INTEGER NOT NULL DEFAULT 0,
    image_file     TEXT,
    tags           TEXT,
    is_featured    INTEGER NOT NULL DEFAULT 0,
    created_at     TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at     TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS services_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id  INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    tags        TEXT,
    UNIQUE (service_id, lang_code)
);

-- ─────────────────────────────────────────────────────────────────
-- ORDERS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id),
    status      TEXT    NOT NULL DEFAULT 'pending',     -- 'pending' | 'verified' | 'paid' | 'shipped' | 'completed' | 'cancelled'
    total       REAL    NOT NULL DEFAULT 0,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS order_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    item_type   TEXT    NOT NULL DEFAULT 'product'
                CHECK (item_type IN ('product', 'service')),  -- 'product' | 'service'
    item_id     INTEGER NOT NULL,
    quantity    INTEGER NOT NULL DEFAULT 1,
    unit_price  REAL    NOT NULL
);

-- ─────────────────────────────────────────────────────────────────
-- CART
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id),
    item_type   TEXT    NOT NULL DEFAULT 'product',
    item_id     INTEGER NOT NULL,
    quantity    INTEGER NOT NULL DEFAULT 1,
    added_at    TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE (user_id, item_type, item_id)
);

-- ─────────────────────────────────────────────────────────────────
-- INQUIRIES
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS inquiries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL,
    subject     TEXT,
    message     TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'new',            -- 'new' | 'read' | 'resolved'
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ─────────────────────────────────────────────────────────────────
-- UI STRINGS
-- ─────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ui_strings (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    key         TEXT    NOT NULL,
    value       TEXT    NOT NULL,
    UNIQUE (lang_code, key)
);

-- ─────────────────────────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_ui_strings_lang    ON ui_strings    (lang_code);
CREATE INDEX IF NOT EXISTS idx_products_category  ON products      (category_id);
CREATE INDEX IF NOT EXISTS idx_products_subcat    ON products      (subcategory_id);
CREATE INDEX IF NOT EXISTS idx_products_brand     ON products      (brand_id);
CREATE INDEX IF NOT EXISTS idx_services_category  ON services      (category_id);
CREATE INDEX IF NOT EXISTS idx_services_subcat    ON services      (subcategory_id);
CREATE INDEX IF NOT EXISTS idx_services_brand     ON services      (brand_id);
CREATE INDEX IF NOT EXISTS idx_subcats_category   ON subcategories (category_id);
CREATE INDEX IF NOT EXISTS idx_orders_user        ON orders        (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status      ON orders        (status);
CREATE INDEX IF NOT EXISTS idx_order_items_order  ON order_items   (order_id);

-- ─────────────────────────────────────────────────────────────────
-- TRIGGERS
-- ─────────────────────────────────────────────────────────────────

-- When order status changes TO 'completed' → increment sales_count
CREATE TRIGGER IF NOT EXISTS trg_order_completed
AFTER UPDATE OF status ON orders
WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    UPDATE products
    SET sales_count = sales_count + (
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM order_items oi
        WHERE oi.order_id = NEW.id
          AND oi.item_type = 'product'
          AND oi.item_id = products.id
    )
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product'
    );

    UPDATE services
    SET sales_count = sales_count + (
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM order_items oi
        WHERE oi.order_id = NEW.id
          AND oi.item_type = 'service'
          AND oi.item_id = services.id
    )
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service'
    );
END;

-- When order status changes FROM 'completed' (reversal/refund) → decrement sales_count
CREATE TRIGGER IF NOT EXISTS trg_order_uncompleted
AFTER UPDATE OF status ON orders
WHEN OLD.status = 'completed' AND NEW.status != 'completed'
BEGIN
    UPDATE products
    SET sales_count = MAX(0, sales_count - (
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM order_items oi
        WHERE oi.order_id = NEW.id
          AND oi.item_type = 'product'
          AND oi.item_id = products.id
    ))
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product'
    );

    UPDATE services
    SET sales_count = MAX(0, sales_count - (
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM order_items oi
        WHERE oi.order_id = NEW.id
          AND oi.item_type = 'service'
          AND oi.item_id = services.id
    ))
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service'
    );
END;