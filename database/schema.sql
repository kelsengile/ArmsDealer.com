-- =========================================
-- FULL DATABASE SCHEMA + INDEXES + TRIGGERS
-- SQLITE EXECUTABLE SCRIPT (COMPLETE)
-- =========================================

BEGIN TRANSACTION;

-- Temporarily disable foreign keys for clean rebuild
PRAGMA foreign_keys = OFF;

-- =========================================
-- USERS
-- =========================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'customer',   -- 'customer' | 'admin'
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- LANGUAGES
-- =========================================
DROP TABLE IF EXISTS languages;
CREATE TABLE languages (
    code TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    locale TEXT NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- =========================================
-- BRANDS
-- =========================================
DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    logo_file TEXT,
    description TEXT,
    is_authorized INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- BRAND TRANSLATIONS
DROP TABLE IF EXISTS brands_translations;
CREATE TABLE brands_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id INTEGER NOT NULL,
    lang_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    UNIQUE (brand_id, lang_code),
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- CATEGORIES
-- =========================================
DROP TABLE IF EXISTS categories;
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL DEFAULT 'product', -- 'product' | 'service'
    icon_file TEXT,
    description TEXT
);

-- CATEGORY TRANSLATIONS
DROP TABLE IF EXISTS category_translations;
CREATE TABLE category_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    lang_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    UNIQUE (category_id, lang_code),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- SUBCATEGORIES
-- =========================================
DROP TABLE IF EXISTS subcategories;
CREATE TABLE subcategories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    icon_file TEXT,
    description TEXT,
    UNIQUE (category_id, name),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- SUBCATEGORY TRANSLATIONS
DROP TABLE IF EXISTS subcategory_translations;
CREATE TABLE subcategory_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    subcategory_id INTEGER NOT NULL,
    lang_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    UNIQUE (subcategory_id, lang_code),
    FOREIGN KEY (subcategory_id) REFERENCES subcategories(id) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- PRODUCTS
-- =========================================
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    category_id INTEGER NOT NULL,
    subcategory_id INTEGER,
    brand_id INTEGER,
    description TEXT,
    price REAL NOT NULL,
    discount REAL DEFAULT 0,
    stock INTEGER NOT NULL DEFAULT 0,
    rating REAL NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count INTEGER NOT NULL DEFAULT 0,
    image_file TEXT,
    tags TEXT,
    is_authorized INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- PRODUCT IMAGES
DROP TABLE IF EXISTS product_images;
CREATE TABLE product_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    image_file TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (product_id, sort_order),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- PRODUCT TRANSLATIONS
DROP TABLE IF EXISTS products_translations;
CREATE TABLE products_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    lang_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    tags TEXT,
    UNIQUE (product_id, lang_code),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- SERVICES
-- =========================================
DROP TABLE IF EXISTS services;
CREATE TABLE services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    category_id INTEGER NOT NULL,
    subcategory_id INTEGER,
    brand_id INTEGER,
    description TEXT,
    price REAL NOT NULL,
    discount REAL DEFAULT 0,
    rating REAL NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count INTEGER NOT NULL DEFAULT 0,
    image_file TEXT,
    tags TEXT,
    is_authorized INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- SERVICE TRANSLATIONS
DROP TABLE IF EXISTS services_translations;
CREATE TABLE services_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id INTEGER NOT NULL,
    lang_code TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    tags TEXT,
    UNIQUE (service_id, lang_code),
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE,
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- ORDERS
-- =========================================
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    total REAL NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ORDER ITEMS
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    item_type TEXT NOT NULL DEFAULT 'product'
        CHECK (item_type IN ('product', 'service')),
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- =========================================
-- CART
-- =========================================
DROP TABLE IF EXISTS cart_items;
CREATE TABLE cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    item_type TEXT NOT NULL DEFAULT 'product',
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    added_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (user_id, item_type, item_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================================
-- CURRENCIES
-- =========================================
DROP TABLE IF EXISTS currencies;
CREATE TABLE currencies (
    code TEXT PRIMARY KEY,
    symbol TEXT NOT NULL,
    label TEXT NOT NULL,
    rate_to_php REAL NOT NULL DEFAULT 1.0,
    is_active INTEGER NOT NULL DEFAULT 1,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- UI STRINGS
-- =========================================
DROP TABLE IF EXISTS ui_strings;
CREATE TABLE ui_strings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lang_code TEXT NOT NULL,
    key TEXT NOT NULL,
    value TEXT NOT NULL,
    UNIQUE (lang_code, key),
    FOREIGN KEY (lang_code) REFERENCES languages(code)
);

-- =========================================
-- INQUIRIES
-- =========================================
DROP TABLE IF EXISTS inquiries;
CREATE TABLE inquiries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    subject TEXT,
    message TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'new',
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- INDEXES (PERFORMANCE OPTIMIZATION)
-- =========================================

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_product_images_product ON product_images(product_id);
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_subcat ON products(subcategory_id);
CREATE INDEX idx_services_brand ON services(brand_id);
CREATE INDEX idx_services_category ON services(category_id);
CREATE INDEX idx_services_subcat ON services(subcategory_id);
CREATE INDEX idx_subcats_category ON subcategories(category_id);
CREATE INDEX idx_ui_strings_lang ON ui_strings(lang_code);

-- =========================================
-- TRIGGERS (AUTO SALES COUNT MANAGEMENT)
-- =========================================

-- When order becomes COMPLETED → add sales
CREATE TRIGGER trg_order_completed
AFTER UPDATE OF status ON orders
WHEN NEW.status = 'completed' AND OLD.status != 'completed'
BEGIN
    UPDATE products
    SET sales_count = sales_count + (
        SELECT COALESCE(SUM(quantity), 0)
        FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product' AND item_id = products.id
    )
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product'
    );

    UPDATE services
    SET sales_count = sales_count + (
        SELECT COALESCE(SUM(quantity), 0)
        FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service' AND item_id = services.id
    )
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service'
    );
END;

-- When order is reverted → subtract sales
CREATE TRIGGER trg_order_uncompleted
AFTER UPDATE OF status ON orders
WHEN OLD.status = 'completed' AND NEW.status != 'completed'
BEGIN
    UPDATE products
    SET sales_count = MAX(0, sales_count - (
        SELECT COALESCE(SUM(quantity), 0)
        FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product' AND item_id = products.id
    ))
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'product'
    );

    UPDATE services
    SET sales_count = MAX(0, sales_count - (
        SELECT COALESCE(SUM(quantity), 0)
        FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service' AND item_id = services.id
    ))
    WHERE id IN (
        SELECT item_id FROM order_items
        WHERE order_id = NEW.id AND item_type = 'service'
    );
END;

-- Re-enable foreign keys
PRAGMA foreign_keys = ON;

COMMIT;