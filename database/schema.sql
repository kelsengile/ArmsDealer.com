-- =========================================
-- FULL DATABASE SCHEMA (SQLITE)
-- =========================================

BEGIN TRANSACTION;


PRAGMA foreign_keys = OFF;

-- =========================================
-- USERS
-- =========================================
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,              -- unique username
    email TEXT NOT NULL UNIQUE,                 -- unique email
    password_hash TEXT NOT NULL,                -- hashed password
    role TEXT NOT NULL DEFAULT 'customer',      -- 'customer' | 'admin'
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- LANGUAGES
-- =========================================
DROP TABLE IF EXISTS languages;
CREATE TABLE languages (
    code TEXT PRIMARY KEY,                      -- e.g. 'en', 'ph'
    label TEXT NOT NULL,                        -- readable name
    locale TEXT NOT NULL,                       -- e.g. 'en_US'
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
    is_authorized INTEGER NOT NULL DEFAULT 1,   -- approved brand
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================================
-- BRAND TRANSLATIONS
-- =========================================
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
    type TEXT NOT NULL DEFAULT 'product',       -- 'product' | 'service'
    icon_file TEXT,
    description TEXT
);

-- =========================================
-- CATEGORY TRANSLATIONS
-- =========================================
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

-- =========================================
-- SUBCATEGORY TRANSLATIONS
-- =========================================
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
    tags TEXT,                                  -- JSON string
    is_authorized INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategories(id),
    FOREIGN KEY (brand_id) REFERENCES brands(id)
);

-- =========================================
-- PRODUCT IMAGES
-- =========================================
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

-- =========================================
-- PRODUCT TRANSLATIONS
-- =========================================
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

-- =========================================
-- SERVICE TRANSLATIONS
-- =========================================
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
    status TEXT NOT NULL DEFAULT 'pending',     -- order lifecycle
    total REAL NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =========================================
-- ORDER ITEMS
-- =========================================
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
-- CART ITEMS
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
-- UI STRINGS (LOCALIZATION)
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
-- INQUIRIES (CONTACT FORM)
-- =========================================
DROP TABLE IF EXISTS inquiries;
CREATE TABLE inquiries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    subject TEXT,
    message TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'new',         -- 'new' | 'read' | 'resolved'
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Re-enable foreign keys
PRAGMA foreign_keys = ON;

COMMIT;