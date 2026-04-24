BEGIN TRANSACTION;
DROP TABLE IF EXISTS "brands";
CREATE TABLE brands (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    slug        TEXT    NOT NULL UNIQUE,
    logo_file   TEXT,
    description TEXT,
    is_active   INTEGER NOT NULL DEFAULT 1,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "brands_translations";
CREATE TABLE "brands_translations" (
	"id"	INTEGER,
	"brand_id"	INTEGER NOT NULL,
	"lang_code"	TEXT NOT NULL,
	"name"	TEXT NOT NULL,
	"description"	TEXT,
	UNIQUE("brand_id","lang_code"),
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("brand_id") REFERENCES "brands"("id") ON DELETE CASCADE,
	FOREIGN KEY("lang_code") REFERENCES "languages"("code")
);
DROP TABLE IF EXISTS "cart_items";
CREATE TABLE cart_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id),
    item_type   TEXT    NOT NULL DEFAULT 'product',
    item_id     INTEGER NOT NULL,
    quantity    INTEGER NOT NULL DEFAULT 1,
    added_at    TEXT    NOT NULL DEFAULT (datetime('now')),
    UNIQUE(user_id, item_type, item_id)
);
DROP TABLE IF EXISTS "categories";
CREATE TABLE categories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL UNIQUE,
    slug        TEXT    NOT NULL UNIQUE,
    type        TEXT    NOT NULL DEFAULT 'product',     -- 'product' | 'service'
    icon_file   TEXT,
    description TEXT
);
DROP TABLE IF EXISTS "category_translations";
CREATE TABLE category_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    UNIQUE (category_id, lang_code)
);
DROP TABLE IF EXISTS "currencies";
CREATE TABLE currencies (
    code        TEXT    PRIMARY KEY,
    symbol      TEXT    NOT NULL,
    label       TEXT    NOT NULL,
    rate_to_php REAL    NOT NULL DEFAULT 1.0,
    is_active   INTEGER NOT NULL DEFAULT 1,
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "inquiries";
CREATE TABLE inquiries (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    email       TEXT NOT NULL,
    subject     TEXT,
    message     TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'new',
    created_at  TEXT NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "languages";
CREATE TABLE languages (
    code        TEXT    PRIMARY KEY,
    label       TEXT    NOT NULL,
    locale      TEXT    NOT NULL,
    is_active   INTEGER NOT NULL DEFAULT 1,
    sort_order  INTEGER NOT NULL DEFAULT 0
);
DROP TABLE IF EXISTS "order_items";
CREATE TABLE order_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id    INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    item_type   TEXT    NOT NULL DEFAULT 'product'     -- 'product' | 'service'
                CHECK (item_type IN ('product', 'service')),
    item_id     INTEGER NOT NULL,
    quantity    INTEGER NOT NULL DEFAULT 1,
    unit_price  REAL    NOT NULL
);
DROP TABLE IF EXISTS "orders";
CREATE TABLE orders (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id),
    status      TEXT    NOT NULL DEFAULT 'pending',     -- 'pending' | 'verified' | 'paid' | 'shipped' | 'completed' | 'cancelled'
    total       REAL    NOT NULL DEFAULT 0,
    notes       TEXT,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "products";
CREATE TABLE products (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL,
    slug            TEXT    NOT NULL UNIQUE,
    category_id     INTEGER NOT NULL REFERENCES categories(id),
    subcategory_id  INTEGER REFERENCES subcategories(id),
    brand_id        INTEGER REFERENCES brands(id),
    description     TEXT,
    price           REAL    NOT NULL,
    discount        REAL    DEFAULT 0,
    stock           INTEGER NOT NULL DEFAULT 0,
    rating          REAL    NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count     INTEGER NOT NULL DEFAULT 0,
    image_file      TEXT,
    tags            TEXT,                               -- JSON array string
    is_featured     INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "products_translations";
CREATE TABLE products_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id  INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    tags        TEXT,
    UNIQUE (product_id, lang_code)
);
DROP TABLE IF EXISTS "services";
CREATE TABLE services (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL,
    slug            TEXT    NOT NULL UNIQUE,
    category_id     INTEGER NOT NULL REFERENCES categories(id),
    subcategory_id  INTEGER REFERENCES subcategories(id),
    brand_id        INTEGER REFERENCES brands(id),
    description     TEXT,
    price           REAL    NOT NULL,
    discount        REAL    DEFAULT 0,
    rating          REAL    NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sales_count     INTEGER NOT NULL DEFAULT 0,
    image_file      TEXT,
    tags            TEXT,
    is_featured     INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);
DROP TABLE IF EXISTS "services_translations";
CREATE TABLE services_translations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    service_id  INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    name        TEXT    NOT NULL,
    description TEXT,
    tags        TEXT,
    UNIQUE (service_id, lang_code)
);
DROP TABLE IF EXISTS "subcategories";
CREATE TABLE subcategories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name        TEXT    NOT NULL,
    slug        TEXT    NOT NULL UNIQUE,
    icon_file   TEXT,
    description TEXT,
    UNIQUE(category_id, name)
);
DROP TABLE IF EXISTS "subcategory_translations";
CREATE TABLE subcategory_translations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    subcategory_id  INTEGER NOT NULL REFERENCES subcategories(id) ON DELETE CASCADE,
    lang_code       TEXT    NOT NULL REFERENCES languages(code),
    name            TEXT    NOT NULL,
    description     TEXT,
    UNIQUE (subcategory_id, lang_code)
);
DROP TABLE IF EXISTS "ui_strings";
CREATE TABLE ui_strings (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    lang_code   TEXT    NOT NULL REFERENCES languages(code),
    key         TEXT    NOT NULL,
    value       TEXT    NOT NULL,
    UNIQUE (lang_code, key)
);
DROP TABLE IF EXISTS "users";
CREATE TABLE users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    email         TEXT    NOT NULL UNIQUE,
    password_hash TEXT    NOT NULL,
    role          TEXT    NOT NULL DEFAULT 'customer',   -- 'customer' | 'admin'
    created_at    TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at    TEXT    NOT NULL DEFAULT (datetime('now'))
);
INSERT INTO "brands" ("id","name","slug","logo_file","description","is_active","created_at","updated_at") VALUES (1,'Colt','colt',NULL,'American firearms manufacturer, makers of the M4 and 1911 platforms.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (2,'Knight''s Armament','knights-armament',NULL,'American defense contractor, designers of the SR-25 marksman rifle.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (3,'Kalashnikov','kalashnikov',NULL,'Russian arms manufacturer, producers of the AK series rifles.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (4,'Glock','glock',NULL,'Austrian pistol manufacturer, standard issue for law enforcement worldwide.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (5,'SIG Sauer','sig-sauer',NULL,'German-Swiss arms manufacturer, producers of the P320 and M17.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (6,'Beretta','beretta',NULL,'Italian arms manufacturer, one of the oldest in the world.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (7,'CZ','cz',NULL,'Czech firearms manufacturer, known for precision engineering.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (8,'Lake City','lake-city',NULL,'US government ammunition plant producing mil-spec 5.56mm and other calibers.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (9,'Sierra Bullets','sierra-bullets',NULL,'American bullet manufacturer, makers of the MatchKing line.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (10,'Custom Forge','custom-forge',NULL,'In-house artisan workshop for hand-forged blades and custom melee weapons.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (11,'Ghost Ops','ghost-ops',NULL,'Specialist services provider for covert operations and surveillance.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14'),
 (12,'Iron Veil','iron-veil',NULL,'Logistics and secure transport specialist for high-value cargo.',1,'2026-04-24 03:49:14','2026-04-24 03:49:14');
INSERT INTO "brands_translations" ("id","brand_id","lang_code","name","description") VALUES (1,1,'filipino','Colt','Amerikanong tagagawa ng baril, gumagawa ng M4 at 1911 platforms.'),
 (2,2,'filipino','Knight''s Armament','Amerikanong kontratista ng depensa, nagdisenyo ng SR-25 marksman rifle.'),
 (3,3,'filipino','Kalashnikov','Rusyanong tagagawa ng armas, gumagawa ng serye ng AK rifles.'),
 (4,4,'filipino','Glock','Awstryanong tagagawa ng pistola, pamantayan ng pagpapatupad ng batas.'),
 (5,5,'filipino','SIG Sauer','Aleman-Suwisong tagagawa ng armas, gumagawa ng P320 at M17.'),
 (6,6,'filipino','Beretta','Italyanong tagagawa ng armas, isa sa pinakamatanda sa mundo.'),
 (7,7,'filipino','CZ','Czech na tagagawa ng baril, kilala sa katumpakan ng inhenyeriya.'),
 (8,8,'filipino','Lake City','Planta ng bala ng gobyerno ng US na gumagawa ng mil-spec 5.56mm.'),
 (9,9,'filipino','Sierra Bullets','Amerikanong tagagawa ng bala, gumagawa ng linya ng MatchKing.'),
 (10,10,'filipino','Custom Forge','In-house artisanong workshop para sa hand-forged na mga talim.'),
 (11,11,'filipino','Ghost Ops','Espesyalistang tagapagbigay ng serbisyo para sa mga lihim na operasyon.'),
 (12,12,'filipino','Iron Veil','Espesyalista sa logistik at ligtas na transportasyon ng mahahalagang kargamento.'),
 (13,1,'japanese','コルト','アメリカの銃器メーカー。M4および1911プラットフォームの製造元。'),
 (14,2,'japanese','ナイツアーマメント','アメリカの防衛企業。SR-25マークスマンライフルの設計者。'),
 (15,3,'japanese','カラシニコフ','ロシアの兵器メーカー。AKシリーズライフルの製造元。'),
 (16,4,'japanese','グロック','オーストリアのピストルメーカー。世界中の法執行機関で標準採用。'),
 (17,5,'japanese','SIGザウアー','ドイツ・スイスの兵器メーカー。P320およびM17の製造元。'),
 (18,6,'japanese','ベレッタ','イタリアの兵器メーカー。世界最古のメーカーの一つ。'),
 (19,7,'japanese','CZ','チェコの銃器メーカー。精密工学で知られる。'),
 (20,8,'japanese','レイクシティ','ミルスペック5.56mm弾などを生産する米国政府の弾薬工場。'),
 (21,9,'japanese','シエラブレッツ','アメリカの弾頭メーカー。MatchKingラインの製造元。'),
 (22,10,'japanese','カスタムフォージ','手鍛造刃物とカスタム近接武器の自社職人工房。'),
 (23,11,'japanese','ゴーストオプス','秘密作戦および監視の専門サービスプロバイダー。'),
 (24,12,'japanese','アイアンヴェール','高価値貨物の物流・安全輸送専門業者。'),
 (25,1,'spanish','Colt','Fabricante de armas americano, creador de las plataformas M4 y 1911.'),
 (26,2,'spanish','Knight''s Armament','Contratista de defensa americano, diseñador del rifle de francotirador SR-25.'),
 (27,3,'spanish','Kalashnikov','Fabricante de armas ruso, productor de la serie de rifles AK.'),
 (28,4,'spanish','Glock','Fabricante de pistolas austriaco, estándar para fuerzas del orden en todo el mundo.'),
 (29,5,'spanish','SIG Sauer','Fabricante de armas alemán-suizo, productor del P320 y el M17.'),
 (30,6,'spanish','Beretta','Fabricante de armas italiano, uno de los más antiguos del mundo.'),
 (31,7,'spanish','CZ','Fabricante de armas checo, conocido por su ingeniería de precisión.'),
 (32,8,'spanish','Lake City','Planta de municiones del gobierno de EE.UU. que produce 5.56mm mil-spec.'),
 (33,9,'spanish','Sierra Bullets','Fabricante de balas americano, creador de la línea MatchKing.'),
 (34,10,'spanish','Custom Forge','Taller artesanal interno para cuchillas forjadas a mano y armas cuerpo a cuerpo.'),
 (35,11,'spanish','Ghost Ops','Proveedor especializado en operaciones encubiertas y vigilancia.'),
 (36,12,'spanish','Iron Veil','Especialista en logística y transporte seguro de carga de alto valor.'),
 (37,1,'mandarin','柯尔特','美国枪械制造商，M4和1911平台的制造者。'),
 (38,2,'mandarin','奈特军备','美国国防承包商，SR-25精确射手步枪的设计者。'),
 (39,3,'mandarin','卡拉什尼科夫','俄罗斯武器制造商，AK系列步枪的生产者。'),
 (40,4,'mandarin','格洛克','奥地利手枪制造商，全球执法机构标准配备。'),
 (41,5,'mandarin','SIG绍尔','德瑞武器制造商，P320和M17的生产者。'),
 (42,6,'mandarin','伯莱塔','意大利武器制造商，全球最古老的制造商之一。'),
 (43,7,'mandarin','CZ','捷克枪械制造商，以精密工程著称。'),
 (44,8,'mandarin','莱克城','美国政府弹药厂，生产军规5.56mm等弹药。'),
 (45,9,'mandarin','塞拉子弹','美国弹头制造商，MatchKing系列的制造者。'),
 (46,10,'mandarin','定制锻造','内部工匠工坊，专注手工锻造刀刃和定制近战武器。'),
 (47,11,'mandarin','幽灵行动','专业隐秘行动和监视服务提供商。'),
 (48,12,'mandarin','铁幕','高价值货物物流和安全运输专家。');
INSERT INTO "categories" ("id","name","slug","type","icon_file","description") VALUES (1,'Firearms','firearms','product',NULL,'Guns and ranged weapons'),
 (2,'Blades','blades','product',NULL,'Knives, swords, and edged weapons'),
 (3,'Blunts','blunts','product',NULL,'Impact weapons like bats and clubs'),
 (4,'Projectile','projectile','product',NULL,'Bows, crossbows, and thrown weapons'),
 (5,'Explosives','explosives','product',NULL,'Explosive devices and materials'),
 (6,'Electronic','electronic','product',NULL,'Electronic warfare tools and devices'),
 (7,'Chemical','chemical','product',NULL,'Chemical-based tools or agents'),
 (8,'Biological','biological','product',NULL,'Biological-related materials'),
 (9,'Vehicle','vehicle','product',NULL,'Vehicles used in operations'),
 (10,'Cyber','cyber','product',NULL,'Cybersecurity and hacking tools'),
 (11,'Security','security','product',NULL,'Security-related equipment'),
 (12,'Ammunition','ammunition','product',NULL,'Bullets, shells, and cartridges'),
 (13,'Protective','protective','product',NULL,'Armor and protective gear'),
 (14,'Tactical','tactical','product',NULL,'Tactical gear and accessories'),
 (15,'Attachments','attachments','product',NULL,'Weapon attachments and add-ons'),
 (16,'Maintenance','maintenance-equipment','product',NULL,'Cleaning and repair tools'),
 (17,'Storage','storage-equipment','product',NULL,'Storage solutions'),
 (18,'Communication','communication','product',NULL,'Radios and communication tools'),
 (19,'Survival','survival','product',NULL,'Survival kits and gear'),
 (20,'Training','training-equipment','product',NULL,'Training tools and aids'),
 (21,'Manufacturing','manufacturing','service',NULL,'Production of equipment and tools'),
 (22,'Customization','customization','service',NULL,'Custom modifications and builds'),
 (23,'Maintenance ','maintenance-service','service',NULL,'Repair and upkeep services'),
 (24,'Transport','transport','service',NULL,'Logistics and transport services'),
 (25,'Storage Services','storage-service','service',NULL,'Secure storage services'),
 (26,'Training Services','training-service','service',NULL,'Skill and operational training'),
 (27,'Protection','protection','service',NULL,'Security and protection services'),
 (28,'Consulting','consulting','service',NULL,'Expert advice and planning'),
 (29,'Research','research','service',NULL,'Research and development'),
 (30,'Testing','testing','service',NULL,'Product and system testing'),
 (31,'Disposal','disposal','service',NULL,'Safe disposal services'),
 (32,'Surveillance','surveillance','service',NULL,'Monitoring and surveillance'),
 (33,'Contracting','contracting','service',NULL,'Contract-based operations');
INSERT INTO "category_translations" ("id","category_id","lang_code","name","description") VALUES (1,1,'filipino','Mga Baril','Mga baril at sandata sa malayo'),
 (2,2,'filipino','Mga Talim','Mga kutsilyo, espada, at matutulis na sandata'),
 (3,3,'filipino','Mga Pamalo','Mga sandata sa pagpukpok tulad ng bat at pamalo'),
 (4,4,'filipino','Proyektil','Busog, crossbow, at mga itinatapon na sandata'),
 (5,5,'filipino','Mga Pagsabog','Mga pagsabog na kagamitan at materyales'),
 (6,6,'filipino','Elektroniko','Mga kagamitan at aparato para sa elektronikong digmaan'),
 (7,7,'filipino','Kemikal','Mga kagamitan o ahente na nakabatay sa kemikal'),
 (8,8,'filipino','Biyolohikal','Mga materyales na may kaugnayan sa biyolohiya'),
 (9,9,'filipino','Sasakyan','Mga sasakyan na ginagamit sa mga operasyon'),
 (10,10,'filipino','Cyber','Mga kagamitan sa cybersecurity at pag-hack'),
 (11,11,'filipino','Seguridad','Mga kagamitan na may kaugnayan sa seguridad'),
 (12,12,'filipino','Bala','Mga bala, shell, at kartutso'),
 (13,13,'filipino','Protektibo','Armor at mga kagamitang pangproteksiyon'),
 (14,14,'filipino','Taktikal','Mga taktikal na kagamitan at aksesorya'),
 (15,15,'filipino','Mga Attachment','Mga attachment at dagdag sa sandata'),
 (16,16,'filipino','Pagpapanatili','Mga kagamitan sa paglilinis at pagkukumpuni'),
 (17,17,'filipino','Imbakan','Mga solusyon sa imbakan'),
 (18,18,'filipino','Komunikasyon','Mga radyo at kagamitan sa komunikasyon'),
 (19,19,'filipino','Kaligtasan','Mga survival kit at kagamitan'),
 (20,20,'filipino','Pagsasanay','Mga kagamitan at tulong sa pagsasanay'),
 (21,21,'filipino','Pagmamanupaktura','Produksyon ng mga kagamitan at kasangkapan'),
 (22,22,'filipino','Kustomisasyon','Mga pasadyang pagbabago at gawa'),
 (23,23,'filipino','Serbisyo sa Pagpapanatili','Mga serbisyo sa pagkukumpuni at pag-aalaga'),
 (24,24,'filipino','Transportasyon','Mga serbisyo sa logistik at transportasyon'),
 (25,25,'filipino','Serbisyo sa Imbakan','Mga ligtas na serbisyo sa imbakan'),
 (26,26,'filipino','Serbisyo sa Pagsasanay','Pagsasanay sa kasanayan at operasyon'),
 (27,27,'filipino','Proteksyon','Mga serbisyo sa seguridad at proteksyon'),
 (28,28,'filipino','Konsultasyon','Dalubhasang payo at pagpaplano'),
 (29,29,'filipino','Pananaliksik','Pananaliksik at pagpapaunlad'),
 (30,30,'filipino','Pagsubok','Pagsubok ng produkto at sistema'),
 (31,31,'filipino','Pagtatapon','Mga ligtas na serbisyo sa pagtatapon'),
 (32,32,'filipino','Pagmamasid','Pagmamatyag at pagsubaybay'),
 (33,33,'filipino','Kontratista','Mga operasyong batay sa kontrata'),
 (34,1,'japanese','銃器','銃および遠距離兵器'),
 (35,2,'japanese','刃物','ナイフ、剣、および刃物系武器'),
 (36,3,'japanese','鈍器','バットや棍棒などの打撃武器'),
 (37,4,'japanese','飛道具','弓、クロスボウ、および投擲武器'),
 (38,5,'japanese','爆発物','爆発装置および爆発物資'),
 (39,6,'japanese','電子機器','電子戦ツールおよびデバイス'),
 (40,7,'japanese','化学兵器','化学物質を用いたツールまたは薬剤'),
 (41,8,'japanese','生物兵器','生物関連素材'),
 (42,9,'japanese','車両','作戦で使用される車両'),
 (43,10,'japanese','サイバー','サイバーセキュリティおよびハッキングツール'),
 (44,11,'japanese','セキュリティ','セキュリティ関連機器'),
 (45,12,'japanese','弾薬','弾丸、砲弾、およびカートリッジ'),
 (46,13,'japanese','防護具','アーマーおよび防護装備'),
 (47,14,'japanese','戦術装備','戦術ギアおよびアクセサリー'),
 (48,15,'japanese','アタッチメント','武器アタッチメントおよびアドオン'),
 (49,16,'japanese','メンテナンス','清掃および修理ツール'),
 (50,17,'japanese','保管','保管ソリューション'),
 (51,18,'japanese','通信','無線機および通信ツール'),
 (52,19,'japanese','サバイバル','サバイバルキットおよび装備'),
 (53,20,'japanese','トレーニング','トレーニングツールおよび補助具'),
 (54,21,'japanese','製造','機器およびツールの生産'),
 (55,22,'japanese','カスタマイズ','カスタム改造およびビルド'),
 (56,23,'japanese','メンテナンスサービス','修理および維持管理サービス'),
 (57,24,'japanese','輸送','物流および輸送サービス'),
 (58,25,'japanese','保管サービス','安全な保管サービス'),
 (59,26,'japanese','トレーニングサービス','スキルおよび作戦トレーニング'),
 (60,27,'japanese','警護','セキュリティおよび保護サービス'),
 (61,28,'japanese','コンサルティング','専門的なアドバイスと計画'),
 (62,29,'japanese','研究','研究および開発'),
 (63,30,'japanese','テスト','製品およびシステムのテスト'),
 (64,31,'japanese','廃棄','安全な廃棄サービス'),
 (65,32,'japanese','監視','モニタリングおよび監視'),
 (66,33,'japanese','契約業務','契約に基づく業務'),
 (67,1,'spanish','Armas de Fuego','Pistolas y armas de largo alcance'),
 (68,2,'spanish','Armas Blancas','Cuchillos, espadas y armas con filo'),
 (69,3,'spanish','Armas Contundentes','Armas de impacto como bates y porras'),
 (70,4,'spanish','Proyectiles','Arcos, ballestas y armas arrojadizas'),
 (71,5,'spanish','Explosivos','Dispositivos y materiales explosivos'),
 (72,6,'spanish','Electrónico','Herramientas y dispositivos de guerra electrónica'),
 (73,7,'spanish','Químico','Herramientas o agentes de base química'),
 (74,8,'spanish','Biológico','Materiales relacionados con agentes biológicos'),
 (75,9,'spanish','Vehículos','Vehículos utilizados en operaciones'),
 (76,10,'spanish','Cibernético','Herramientas de ciberseguridad y hacking'),
 (77,11,'spanish','Seguridad','Equipos relacionados con la seguridad'),
 (78,12,'spanish','Munición','Balas, proyectiles y cartuchos'),
 (79,13,'spanish','Protector','Armadura y equipo de protección'),
 (80,14,'spanish','Táctico','Equipo táctico y accesorios'),
 (81,15,'spanish','Accesorios','Accesorios y complementos para armas'),
 (82,16,'spanish','Mantenimiento','Herramientas de limpieza y reparación'),
 (83,17,'spanish','Almacenamiento','Soluciones de almacenamiento'),
 (84,18,'spanish','Comunicación','Radios y herramientas de comunicación'),
 (85,19,'spanish','Supervivencia','Kits y equipo de supervivencia'),
 (86,20,'spanish','Entrenamiento','Herramientas y ayudas de entrenamiento'),
 (87,21,'spanish','Fabricación','Producción de equipos y herramientas'),
 (88,22,'spanish','Personalización','Modificaciones y construcciones personalizadas'),
 (89,23,'spanish','Servicio de Mantenimiento','Servicios de reparación y mantenimiento'),
 (90,24,'spanish','Transporte','Servicios de logística y transporte'),
 (91,25,'spanish','Servicios de Almacenamiento','Servicios de almacenamiento seguro'),
 (92,26,'spanish','Servicios de Entrenamiento','Entrenamiento de habilidades y operaciones'),
 (93,27,'spanish','Protección','Servicios de seguridad y protección'),
 (94,28,'spanish','Consultoría','Asesoramiento experto y planificación'),
 (95,29,'spanish','Investigación','Investigación y desarrollo'),
 (96,30,'spanish','Pruebas','Pruebas de productos y sistemas'),
 (97,31,'spanish','Eliminación','Servicios de eliminación segura'),
 (98,32,'spanish','Vigilancia','Monitoreo y vigilancia'),
 (99,33,'spanish','Contratación','Operaciones basadas en contratos'),
 (100,1,'mandarin','枪械','枪支和远程武器'),
 (101,2,'mandarin','刀刃','刀具、剑及刃器武器'),
 (102,3,'mandarin','钝器','球棒和棍棒等冲击性武器'),
 (103,4,'mandarin','投射物','弓、弩及投掷武器'),
 (104,5,'mandarin','爆炸物','爆炸装置及材料'),
 (105,6,'mandarin','电子设备','电子战工具和设备'),
 (106,7,'mandarin','化学品','化学类工具或制剂'),
 (107,8,'mandarin','生物材料','与生物相关的材料'),
 (108,9,'mandarin','车辆','用于行动的车辆'),
 (109,10,'mandarin','网络','网络安全和黑客工具'),
 (110,11,'mandarin','安保','安保相关设备'),
 (111,12,'mandarin','弹药','子弹、炮弹和弹筒'),
 (112,13,'mandarin','防护装备','盔甲和防护装备'),
 (113,14,'mandarin','战术装备','战术装备和配件'),
 (114,15,'mandarin','附件','武器附件和配件'),
 (115,16,'mandarin','维护','清洁和修理工具'),
 (116,17,'mandarin','存储','存储解决方案'),
 (117,18,'mandarin','通信','无线电和通信工具'),
 (118,19,'mandarin','生存','生存套件和装备'),
 (119,20,'mandarin','训练','训练工具和辅助设备'),
 (120,21,'mandarin','制造','设备和工具的生产'),
 (121,22,'mandarin','定制','定制改装和制造'),
 (122,23,'mandarin','维护服务','维修和保养服务'),
 (123,24,'mandarin','运输','物流和运输服务'),
 (124,25,'mandarin','存储服务','安全存储服务'),
 (125,26,'mandarin','培训服务','技能和作战培训'),
 (126,27,'mandarin','保护','安保和保护服务'),
 (127,28,'mandarin','咨询','专家建议和规划'),
 (128,29,'mandarin','研究','研究和开发'),
 (129,30,'mandarin','测试','产品和系统测试'),
 (130,31,'mandarin','处置','安全处置服务'),
 (131,32,'mandarin','监控','监测和监视'),
 (132,33,'mandarin','承包','基于合同的运营');
INSERT INTO "currencies" ("code","symbol","label","rate_to_php","is_active","updated_at") VALUES ('PHP','₱','PHP (₱)',1.0,1,'2026-04-24 03:34:57'),
 ('USD','$','USD ($)',0.0175,1,'2026-04-24 03:34:57'),
 ('EUR','€','EUR (€)',0.0162,1,'2026-04-24 03:34:57'),
 ('JPY','¥','JPY (JP¥)',2.627,1,'2026-04-14 06:58:41'),
 ('CNY','¥','CNY (CN¥)',0.127,1,'2026-04-14 06:58:41');
INSERT INTO "languages" ("code","label","locale","is_active","sort_order") VALUES ('english','English','en',1,1),
 ('filipino','Filipino','fil',1,2),
 ('japanese','Japanese','ja',1,3),
 ('spanish','Spanish','es',1,4),
 ('mandarin','Mandarin','zh',1,5);
INSERT INTO "products" ("id","name","slug","category_id","subcategory_id","brand_id","description","price","discount","stock","rating","sales_count","image_file","tags","is_featured","created_at","updated_at") VALUES (1,'M4A1 Carbine','m4a1-carbine-tactical',1,1,1,'Semi-automatic 5.56mm carbine. Cold-hammer-forged barrel, M-LOK handguard, mil-spec trigger group. Trusted in over 80 military forces worldwide.',185000.0,25.0,10,4.8,142,'m14carbine.jpg','["5.56mm","Semi-Auto","M-LOK"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (2,'SR-25 Rifle','sr-25-precision-rifle',1,6,2,'7.62mm semi-auto marksman rifle. Match-grade stainless barrel, adjustable stock, Picatinny rail system. Effective range: 800m.',230000.0,15.0,5,4.9,87,'sr25marksman.jpg','["7.62mm","DMR","Precision"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (3,'AK-103 Assault Rifle','ak-103-assault-rifle',1,1,3,'7.62x39mm battle-proven platform. Side-folding stock, chrome-lined barrel, enhanced pistol grip. Legendary reliability in adverse conditions.',145000.0,21.0,8,4.7,203,'ak103.jpg','["7.62x39","AK Platform","Folding Stock"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (4,'Glock 17 Gen5','glock-17-gen5',1,2,4,'9mm striker-fired duty pistol. Marksman barrel, flared mag well, ambidextrous slide stop. Standard issue across 50+ law enforcement agencies.',68000.0,20.0,20,4.9,318,'glock17gen5.jpg','["9mm","Gen5","LE Standard"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (5,'1911 C.O.','1911-custom-operator',1,2,1,'.45 ACP single-action platform. Match barrel bushing, extended beavertail, G10 grips. Classic reliability, modern upgrades.',95000.0,20.0,6,4.6,74,'1911operator.jpg','[".45 ACP","1911","Single-Action"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (6,'SIG P320 Compact','sig-p320-compact',1,2,5,'9mm modular pistol system. Serialized fire control unit, interchangeable grip modules. US Army M17 basis.',82000.0,15.0,12,4.8,156,'sigp320.jpg','["9mm","Modular","Compact"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (7,'Beretta M9A3','beretta-m9a3',1,2,6,'9mm DA/SA pistol. Vertec grip, decocker/safety, extended tang. Time-tested military sidearm with modern enhancements.',74500.0,20.0,9,4.5,98,'berettam9a3.jpg','["9mm","DA/SA","Military"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (8,'CZ P-10F','cz-p10f-full-size',1,2,7,'9mm striker-fired pistol. Interchangeable back straps, suppressor-ready, Omega trigger. Czech precision engineering.',71000.0,20.0,11,4.7,112,'czp10f.jpg','["9mm","Striker","Full-Size"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (9,'Miyamoto Katana','miyamoto-katana-damascus',2,7,10,'Hand-forged Damascus steel katana. Traditional differential hardening, ray skin handle wrap, lacquered wooden saya.',42000.0,20.0,4,4.9,39,'miyamotokatana.jpg','["Damascus","Katana","Handforged"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (10,'Balisong','balisong',2,10,10,'Traditional Filipino butterfly knife. Skeletonized handles, latch mechanism, balanced for flipping. Stainless steel blade.',28000.0,20.0,15,4.6,61,'balisong.jpg','["Balisong","Butterfly Knife","Filipino"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (11,'Italian Stiletto','italian-stiletto',2,10,10,'Classic Italian switchblade stiletto. Slim profile, spring-assisted deployment, stainless steel blade with horn handle.',8500.0,20.0,18,4.3,88,'stiletto.jpg','["Stiletto","Switchblade","Italian"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (12,'5.56mm NATO','5-56mm-nato-1000-rounds',12,13,8,'M855 62gr green-tip penetrator. Lake City production, mil-spec brass, boxer-primed. Optimized for AR-platform rifles.',18500.0,25.0,50,4.8,274,'5.56.jpg','["M855","62gr","1000 Rounds"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (13,'9mm FMJ','9mm-fmj-500-rounds',12,14,8,'124gr full metal jacket 9mm. Reloadable brass, consistent velocity, clean-burning powder. Ideal for training.',6200.0,25.0,100,4.7,431,'9mmfmj.jpg','["124gr FMJ","9mm","Training"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (14,'7.62x39mm','7-62x39mm-500-rounds',12,13,3,'122gr FMJ steel-core 7.62x39. Corrosion-resistant, lacquered steel case. Optimized for AK-platform rifles.',9500.0,15.0,75,4.6,198,'7.62x39.jpg','["122gr","Steel Case","AK Platform"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (15,'.45 ACP HP','45-acp-hp-200-rounds',12,14,9,'230gr jacketed hollow point. Controlled expansion, bonded core, nickel-plated brass. Duty and self-defense rated.',7800.0,20.0,60,4.8,167,'45acp.jpg','["JHP","230gr","Duty Round"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02'),
 (16,'.308 Win Match','308-win-match-100-rounds',12,16,9,'168gr BTHP match grade .308 Winchester. Sierra MatchKing projectile, consistent OAL, sub-MOA accuracy guaranteed.',8900.0,20.0,40,4.9,93,'308winmatch.jpg','["168gr BTHP","Match Grade","Sub-MOA"]',1,'2026-04-10 15:12:02','2026-04-10 15:12:02');
INSERT INTO "products_translations" ("id","product_id","lang_code","name","description","tags") VALUES (1,1,'filipino','M4A1 Carbine','Semi-otomatikong karbina na 5.56mm. Cold-hammer-forged na tubo, M-LOK handguard, mil-spec trigger group. Pinagkakatiwalaan ng mahigit 80 hukbong militar sa buong mundo.','["5.56mm","Semi-Auto","M-LOK"]'),
 (2,2,'filipino','SR-25 Rifle','7.62mm semi-auto marksman rifle. Match-grade stainless na tubo, naaayos na stock, Picatinny rail system. Epektibong hanay: 800m.','["7.62mm","DMR","Katumpakan"]'),
 (3,3,'filipino','AK-103 Assault Rifle','7.62x39mm battle-proven na plataporma. Side-folding stock, chrome-lined na tubo, pinahusay na pistol grip. Kilalang tibay sa mahirap na kondisyon.','["7.62x39","AK Platform","Nakatiklop na Stock"]'),
 (4,4,'filipino','Glock 17 Gen5','9mm striker-fired duty pistol. Marksman barrel, flared mag well, ambidextrous slide stop. Pamantayang isyu sa mahigit 50 ahensya ng pagpapatupad ng batas.','["9mm","Gen5","LE Standard"]'),
 (5,5,'filipino','1911 C.O.','.45 ACP single-action na plataporma. Match barrel bushing, extended beavertail, G10 grips. Klasikong pagiging maaasahan, modernong mga pagpapabuti.','[".45 ACP","1911","Single-Action"]'),
 (6,6,'filipino','SIG P320 Compact','9mm modular pistol system. Serialized fire control unit, palipat-lipat na grip modules. Batayan ng US Army M17.','["9mm","Modular","Compact"]'),
 (7,7,'filipino','Beretta M9A3','9mm DA/SA pistol. Vertec grip, decocker/safety, extended tang. Nasubok na militar na sidearm na may modernong pagpapahusay.','["9mm","DA/SA","Militar"]'),
 (8,8,'filipino','CZ P-10F','9mm striker-fired pistol. Palipat-lipat na back straps, suppressor-ready, Omega trigger. Czech precision engineering.','["9mm","Striker","Full-Size"]'),
 (9,9,'filipino','Miyamoto Katana','Kamay-forged Damascus steel katana. Tradisyonal na differential hardening, ray skin handle wrap, lacquered na kahoy na saya.','["Damascus","Katana","Kamay-Forged"]'),
 (10,10,'filipino','Balisong','Tradisyonal na Pilipinong butterfly knife. Skeletonized handles, latch mechanism, balanse para sa flipping. Stainless steel blade.','["Balisong","Butterfly Knife","Pilipino"]'),
 (11,11,'filipino','Italian Stiletto','Klasikong Italian switchblade stiletto. Manipis na profile, spring-assisted na deployment, stainless steel blade na may horn handle.','["Stiletto","Switchblade","Italyano"]'),
 (12,12,'filipino','5.56mm NATO','M855 62gr green-tip penetrator. Lake City production, mil-spec brass, boxer-primed. Optimized para sa AR-platform rifles.','["M855","62gr","1000 Bala"]'),
 (13,13,'filipino','9mm FMJ','124gr full metal jacket 9mm. Reloadable brass, tuloy-tuloy na bilis, malinis na nasusunog na pulbos. Ideal para sa pagsasanay.','["124gr FMJ","9mm","Pagsasanay"]'),
 (14,14,'filipino','7.62x39mm','122gr FMJ steel-core 7.62x39. Corrosion-resistant, lacquered steel case. Optimized para sa AK-platform rifles.','["122gr","Steel Case","AK Platform"]'),
 (15,15,'filipino','.45 ACP HP','230gr jacketed hollow point. Controlled expansion, bonded core, nickel-plated brass. Duty at self-defense rated.','["JHP","230gr","Duty Round"]'),
 (16,16,'filipino','.308 Win Match','168gr BTHP match grade .308 Winchester. Sierra MatchKing projectile, tuloy-tuloy na OAL, sub-MOA accuracy garantisado.','["168gr BTHP","Match Grade","Sub-MOA"]'),
 (17,1,'japanese','M4A1カービン','5.56mmセミオートカービン。コールドハンマーフォージバレル、M-LOKハンドガード、ミルスペックトリガーグループ。世界80以上の軍で採用。','["5.56mm","セミオート","M-LOK"]'),
 (18,2,'japanese','SR-25ライフル','7.62mmセミオートマークスマンライフル。マッチグレードステンレスバレル、調整可能ストック、ピカティニーレールシステム。有効射程800m。','["7.62mm","DMR","精密"]'),
 (19,3,'japanese','AK-103アサルトライフル','7.62x39mm実戦実績プラットフォーム。サイドフォールディングストック、クロムライニングバレル、強化ピストルグリップ。過酷な環境での信頼性。','["7.62x39","AKプラットフォーム","折りたたみストック"]'),
 (20,4,'japanese','グロック17 Gen5','9mmストライカー式デューティーピストル。マークスマンバレル、フレアードマグウェル、両手用スライドストップ。50以上の法執行機関で標準採用。','["9mm","Gen5","LE標準"]'),
 (21,5,'japanese','1911 C.O.','.45 ACP シングルアクションプラットフォーム。マッチバレルブッシング、拡張ビーバーテール、G10グリップ。クラシックな信頼性、現代的な改良。','[".45 ACP","1911","シングルアクション"]'),
 (22,6,'japanese','SIG P320コンパクト','9mmモジュラーピストルシステム。シリアル化ファイアコントロールユニット、交換可能グリップモジュール。米陸軍M17の基盤。','["9mm","モジュラー","コンパクト"]'),
 (23,7,'japanese','ベレッタ M9A3','9mm DA/SAピストル。バーテックグリップ、デコッカー/セーフティ、拡張タング。現代的な改良を加えた実績ある軍用サイドアーム。','["9mm","DA/SA","ミリタリー"]'),
 (24,8,'japanese','CZ P-10F','9mmストライカー式ピストル。交換可能バックストラップ、サプレッサー対応、オメガトリガー。チェコの精密工学。','["9mm","ストライカー","フルサイズ"]'),
 (25,9,'japanese','宮本カタナ','手鍛造ダマスカス鋼刀。伝統的な焼き入れ、エイ皮柄巻き、漆塗り木鞘。','["ダマスカス","カタナ","手鍛造"]'),
 (26,10,'japanese','バリソン','伝統的なフィリピンのバタフライナイフ。スケルトンハンドル、ラッチ機構、フリッピング用バランス。ステンレス鋼ブレード。','["バリソン","バタフライナイフ","フィリピン"]'),
 (27,11,'japanese','イタリアンスティレット','クラシックなイタリアンスイッチブレードスティレット。スリムプロファイル、スプリングアシスト展開、ホーンハンドル付きステンレス鋼ブレード。','["スティレット","スイッチブレード","イタリア"]'),
 (28,12,'japanese','5.56mm NATO弾','M855 62グリーンチップ貫通弾。レイクシティ生産、ミルスペックブラス、ボクサープライム。ARプラットフォームライフル最適化。','["M855","62gr","1000発"]'),
 (29,13,'japanese','9mm FMJ弾','124gr フルメタルジャケット9mm。再装填可能ブラス、安定した初速、クリーン燃焼火薬。訓練に最適。','["124gr FMJ","9mm","訓練用"]'),
 (30,14,'japanese','7.62x39mm弾','122gr FMJスチールコア7.62x39。耐食性、ラッカーコートスチールケース。AKプラットフォームライフル最適化。','["122gr","スチールケース","AKプラットフォーム"]'),
 (31,15,'japanese','.45 ACP HP弾','230gr ジャケットホローポイント。制御拡張、ボンドコア、ニッケルメッキブラス。デューティー・護身用評価済み。','["JHP","230gr","デューティーラウンド"]'),
 (32,16,'japanese','.308 Winマッチ弾','168gr BTHP マッチグレード.308ウィンチェスター。シエラマッチキング弾、安定OAL、サブMOA精度保証。','["168gr BTHP","マッチグレード","サブMOA"]'),
 (33,1,'spanish','Carabina M4A1','Carabina semiautomática de 5.56mm. Cañón forjado en frío, guardamano M-LOK, grupo de gatillo mil-spec. Utilizada por más de 80 fuerzas militares en todo el mundo.','["5.56mm","Semiautomática","M-LOK"]'),
 (34,2,'spanish','Rifle SR-25','Rifle de francotirador semiautomático de 7.62mm. Cañón de acero inoxidable match-grade, culata ajustable, sistema de raíl Picatinny. Alcance efectivo: 800m.','["7.62mm","DMR","Precisión"]'),
 (35,3,'spanish','Rifle de Asalto AK-103','Plataforma 7.62x39mm probada en combate. Culata plegable lateral, cañón cromado, empuñadura mejorada. Confiabilidad legendaria en condiciones adversas.','["7.62x39","Plataforma AK","Culata Plegable"]'),
 (36,4,'spanish','Glock 17 Gen5','Pistola de servicio 9mm accionada por percutor. Cañón Marksman, pozo de cargador acampanado, tope de corredera ambidiestro. Estándar en más de 50 agencias policiales.','["9mm","Gen5","Estándar Policial"]'),
 (37,5,'spanish','1911 C.O.','Plataforma de acción simple .45 ACP. Buje de cañón match, cola de castor extendida, cachas G10. Confiabilidad clásica con mejoras modernas.','[".45 ACP","1911","Acción Simple"]'),
 (38,6,'spanish','SIG P320 Compacta','Sistema de pistola modular 9mm. Unidad de control de fuego serializada, módulos de empuñadura intercambiables. Base del M17 del Ejército de EE.UU.','["9mm","Modular","Compacta"]'),
 (39,7,'spanish','Beretta M9A3','Pistola DA/SA de 9mm. Empuñadura Vertec, desarmador/seguro, cola extendida. Pistola militar probada con mejoras modernas.','["9mm","DA/SA","Militar"]'),
 (40,8,'spanish','CZ P-10F','Pistola de percutor 9mm de tamaño completo. Correas traseras intercambiables, lista para supresor, gatillo Omega. Ingeniería de precisión checa.','["9mm","Percutor","Tamaño Completo"]'),
 (41,9,'spanish','Katana Miyamoto','Katana de acero de Damasco forjada a mano. Endurecimiento diferencial tradicional, mango envuelto en piel de raya, saya de madera lacada.','["Damasco","Katana","Forjada a Mano"]'),
 (42,10,'spanish','Balisong','Navaja mariposa filipina tradicional. Mangos esqueletizados, mecanismo de pestillo, equilibrada para voltear. Hoja de acero inoxidable.','["Balisong","Navaja Mariposa","Filipina"]'),
 (43,11,'spanish','Estilete Italiano','Estilete navaja automática italiano clásico. Perfil delgado, despliegue asistido por resorte, hoja de acero inoxidable con mango de cuerno.','["Estilete","Navaja Automática","Italiano"]'),
 (44,12,'spanish','5.56mm OTAN','Penetrador M855 de 62gr punta verde. Producción Lake City, latón mil-spec, cebado boxer. Optimizado para rifles de plataforma AR.','["M855","62gr","1000 Rondas"]'),
 (45,13,'spanish','9mm FMJ','124gr encamisado completo 9mm. Latón recargable, velocidad consistente, pólvora de combustión limpia. Ideal para entrenamiento.','["124gr FMJ","9mm","Entrenamiento"]'),
 (46,14,'spanish','7.62x39mm','122gr FMJ núcleo de acero 7.62x39. Resistente a la corrosión, estuche de acero lacado. Optimizado para rifles de plataforma AK.','["122gr","Estuche de Acero","Plataforma AK"]'),
 (47,15,'spanish','.45 ACP HP','230gr punta hueca encamisada. Expansión controlada, núcleo unido, latón niquelado. Clasificado para servicio y defensa personal.','["JHP","230gr","Ronda de Servicio"]'),
 (48,16,'spanish','.308 Win Match','168gr BTHP match grade .308 Winchester. Proyectil Sierra MatchKing, OAL consistente, precisión sub-MOA garantizada.','["168gr BTHP","Match Grade","Sub-MOA"]'),
 (49,1,'mandarin','M4A1卡宾枪','5.56mm半自动卡宾枪。冷锻枪管，M-LOK护木，军规扳机组。被全球80余支军事力量采用。','["5.56mm","半自动","M-LOK"]'),
 (50,2,'mandarin','SR-25步枪','7.62mm半自动精确射手步枪。比赛级不锈钢枪管，可调托架，皮卡汀尼导轨系统。有效射程：800米。','["7.62mm","DMR","精准"]'),
 (51,3,'mandarin','AK-103突击步枪','经实战验证的7.62x39mm平台。侧折叠托架，镀铬枪管，增强手枪握把。在恶劣环境中可靠性卓越。','["7.62x39","AK平台","折叠托架"]'),
 (52,4,'mandarin','格洛克17 Gen5','9mm击针式执勤手枪。精确射手枪管，喇叭形弹匣口，双手通用滑套停止键。被50余家执法机构列为标配。','["9mm","Gen5","执法标配"]'),
 (53,5,'mandarin','1911 C.O.','.45 ACP单动平台。比赛级枪管衬套，延长护手，G10握板。经典可靠性与现代升级的结合。','[".45 ACP","1911","单动"]'),
 (54,6,'mandarin','SIG P320紧凑型','9mm模块化手枪系统。序列化击发控制单元，可互换握把模块。美国陆军M17的基础。','["9mm","模块化","紧凑型"]'),
 (55,7,'mandarin','伯莱塔M9A3','9mm双动/单动手枪。Vertec握把，待击解除/保险，延长护手。经过验证的军用副武器，配备现代改进。','["9mm","DA/SA","军用"]'),
 (56,8,'mandarin','CZ P-10F','9mm全尺寸击针式手枪。可互换后背板，抑制器就绪，Omega扳机。捷克精密工程。','["9mm","击针式","全尺寸"]'),
 (57,9,'mandarin','宫本武藏武士刀','手工锻造大马士革钢武士刀。传统差异硬化，鲨鱼皮缠柄，漆制木鞘。','["大马士革","武士刀","手工锻造"]'),
 (58,10,'mandarin','巴利松蝴蝶刀','传统菲律宾蝴蝶刀。镂空刀柄，锁扣机构，平衡设计便于旋转。不锈钢刀刃。','["巴利松","蝴蝶刀","菲律宾"]'),
 (59,11,'mandarin','意大利细刃刀','经典意大利弹簧刀。纤细外形，弹簧辅助展开，带角柄不锈钢刀刃。','["细刃刀","弹簧刀","意大利"]'),
 (60,12,'mandarin','5.56mm北约弹','M855 62格林头穿甲弹。莱克城生产，军规黄铜，拳击底火。针对AR平台步枪优化。','["M855","62gr","1000发"]'),
 (61,13,'mandarin','9mm FMJ弹','124格全金属被甲9mm。可复装黄铜，速度稳定，清洁燃烧火药。适合训练使用。','["124gr FMJ","9mm","训练"]'),
 (62,14,'mandarin','7.62x39mm弹','122格FMJ钢芯7.62x39。耐腐蚀，漆涂钢壳。针对AK平台步枪优化。','["122gr","钢壳","AK平台"]'),
 (63,15,'mandarin','.45 ACP HP弹','230格被甲空心弹。可控膨胀，粘合弹芯，镀镍黄铜。执勤及自卫评级。','["JHP","230gr","执勤弹"]'),
 (64,16,'mandarin','.308 Win比赛弹','168格BTHP比赛级.308温彻斯特。塞拉比赛王弹头，稳定全弹长，保证亚MOA精度。','["168gr BTHP","比赛级","亚MOA"]');
INSERT INTO "services" ("id","name","slug","category_id","subcategory_id","brand_id","description","price","discount","rating","sales_count","image_file","tags","is_featured","created_at","updated_at") VALUES (1,'Assassination','assassination',32,17,11,'Complete weapon inspection, deep clean, barrel crown recutting, trigger job, parts replacement, test fire report. 72-hour turnaround.',12000000.0,20.0,4.7,23,'assassination.jpg','["Full Service","72hr Turnaround","Certified"]',1,'2026-04-12 10:39:10','2026-04-12 10:39:10'),
 (2,'Clean Up','clean-up',32,18,11,'Mil-spec Cerakote application in any color or camo pattern. Surface prep, bead blast, cure. Rated to 1,200°F. UV, chemical, and corrosion resistant.',250000.0,20.0,4.5,41,'cleanup.jpg','["Cerakote","Custom Color","Mil-Spec"]',1,'2026-04-12 10:39:10','2026-04-12 10:39:10'),
 (3,'Delivery','delivery',25,19,12,'Professional scope mounting, torque to spec, lapping, and 100m zeroing session on our range. Includes bore-sight and verification target.',85000.0,25.0,4.6,67,'delivery.jpg','["Mounting","Zeroing","Range Included"]',1,'2026-04-12 10:39:10','2026-04-12 10:39:10');
INSERT INTO "services_translations" ("id","service_id","lang_code","name","description","tags") VALUES (1,1,'filipino','Asasinasyon','Kumpletong inspeksyon ng armas, malalim na paglilinis, muling pagputol ng crown ng tubo, trigger job, kapalit na mga parte, ulat ng pagsubok na pagpapaputok. 72 oras na pagbabalik.','["Buong Serbisyo","72hr Pagbabalik","Sertipikado"]'),
 (2,2,'filipino','Paglilinis','Mil-spec Cerakote na aplikasyon sa anumang kulay o camo pattern. Paghahanda ng ibabaw, bead blast, pagbabago. Rated sa 1,200°F. UV, kemikal, at corrosion resistant.','["Cerakote","Custom na Kulay","Mil-Spec"]'),
 (3,3,'filipino','Paghahatid','Propesyonal na pag-mount ng scope, torque sa spec, lapping, at 100m zeroing session sa aming range. Kasama ang bore-sight at verification target.','["Pag-mount","Zeroing","Range Kasama"]'),
 (4,1,'japanese','暗殺','完全な武器点検、徹底的なクリーニング、バレルクラウン再切削、トリガー調整、部品交換、試射レポート。72時間納期。','["フルサービス","72時間納期","認定済み"]'),
 (5,2,'japanese','清掃','ミルスペックCerakote塗装、任意の色またはカモパターン。表面処理、ビードブラスト、硬化。1,200°F耐熱。UV・化学・腐食耐性。','["Cerakote","カスタムカラー","ミルスペック"]'),
 (6,3,'japanese','配達','スコープ取り付け、トルク規定、ラッピング、100mゼロイングセッション。ボアサイトと検証ターゲット付き。','["取り付け","ゼロイング","レンジ込み"]'),
 (7,1,'spanish','Asesinato','Inspección completa del arma, limpieza profunda, retalado de la corona del cañón, ajuste del gatillo, reemplazo de piezas, informe de prueba de disparo. Entrega en 72 horas.','["Servicio Completo","Entrega 72hr","Certificado"]'),
 (8,2,'spanish','Limpieza','Aplicación de Cerakote mil-spec en cualquier color o patrón de camuflaje. Preparación de superficie, granallado, curado. Clasificado a 1,200°F. Resistente a UV, químicos y corrosión.','["Cerakote","Color Personalizado","Mil-Spec"]'),
 (9,3,'spanish','Entrega','Montaje profesional de mira, torque según especificaciones, lapeado y sesión de zeroing a 100m en nuestro campo. Incluye bore-sight y objetivo de verificación.','["Montaje","Zeroing","Campo Incluido"]'),
 (10,1,'mandarin','暗杀','完整武器检查、深度清洁、枪管冠部重新切削、扳机调整、零件更换、试射报告。72小时交付。','["全套服务","72小时交付","认证"]'),
 (11,2,'mandarin','清理','军规Cerakote涂层，任何颜色或迷彩图案。表面处理、喷砂、固化。耐温1,200°F，抗UV、化学品及腐蚀。','["Cerakote","定制颜色","军规"]'),
 (12,3,'mandarin','配送','专业瞄准镜安装、扭矩规范、研磨，以及在我们靶场进行的100米归零校准。包含激光校准和验证靶标。','["安装","归零","含靶场"]');
INSERT INTO "subcategories" ("id","category_id","name","slug","icon_file","description") VALUES (1,1,'Rifles','rifles',NULL,'Long-barreled shoulder-fired firearms'),
 (2,1,'Pistols','pistols',NULL,'Short-barreled sidearms'),
 (3,1,'Shotguns','shotguns',NULL,'Smoothbore shoulder arms'),
 (4,1,'Submachine Guns','submachine-guns',NULL,'Compact automatic firearms'),
 (5,1,'Machine Guns','machine-guns',NULL,'Belt or magazine-fed automatic weapons'),
 (6,1,'Sniper Rifles','sniper-rifles',NULL,'Long-range precision rifles'),
 (7,2,'Swords','swords',NULL,'Long bladed weapons for two-handed use'),
 (8,2,'Knives','knives',NULL,'Short single or double-edged blades'),
 (9,2,'Daggers','daggers',NULL,'Double-edged stabbing weapons'),
 (10,2,'Folding Knives','folding-knives',NULL,'Pocket and assisted-open folders'),
 (11,3,'Batons','batons',NULL,'Police and tactical striking sticks'),
 (12,3,'Clubs','clubs',NULL,'Heavy impact weapons'),
 (13,12,'Rifle Ammo','rifle-ammo',NULL,'Centerfire rifle cartridges'),
 (14,12,'Pistol Ammo','pistol-ammo',NULL,'Handgun cartridges'),
 (15,12,'Shotgun Shells','shotgun-shells',NULL,'Smoothbore shotgun ammunition'),
 (16,12,'Specialty Ammo','specialty-ammo',NULL,'Armor-piercing, tracer, and match rounds'),
 (17,32,'Wet Operations','wet-operations',NULL,'Direct action and elimination contracts'),
 (18,32,'Site Operations','site-operations',NULL,'Location cleanup and evidence disposal'),
 (19,25,'Secure Delivery','secure-delivery',NULL,'Covert and secure item transport'),
 (20,15,'Optics','optics',NULL,'Scopes, red dots, and magnifiers'),
 (21,15,'Suppressors','suppressors',NULL,'Sound and flash suppressors'),
 (22,15,'Grips & Stocks','grips-stocks',NULL,'Ergonomic grip and stock options');
INSERT INTO "subcategory_translations" ("id","subcategory_id","lang_code","name","description") VALUES (1,1,'filipino','Mga Riple','Mga baril na may mahabang tubo para sa balikat'),
 (2,2,'filipino','Mga Pistola','Mga maikling baril na pantulong'),
 (3,3,'filipino','Mga Shotgun','Mga baril na walang rayado sa tubo'),
 (4,4,'filipino','Mga Submachine Gun','Mga kompaktong awtomatikong baril'),
 (5,5,'filipino','Mga Machine Gun','Mga awtomatikong sandata na may belt o magazine'),
 (6,6,'filipino','Mga Sniper Rifle','Mga riple para sa malayo at tumpak na pamamaril'),
 (7,7,'filipino','Mga Espada','Mga mahabang talim para sa dalawang kamay'),
 (8,8,'filipino','Mga Kutsilyo','Mga maikling talim na may isa o dalawang gilid'),
 (9,9,'filipino','Mga Daga','Mga talim na may dalawang gilid para sa saksak'),
 (10,10,'filipino','Mga Folding Knife','Mga nakatiklop na kutsilyo para sa bulsa'),
 (11,11,'filipino','Mga Baton','Mga pamukpok para sa pulisya at taktikal'),
 (12,12,'filipino','Mga Pamalo','Mabibigat na mga sandata sa pagpukpok'),
 (13,13,'filipino','Bala ng Riple','Mga kartutso ng sentriprong riple'),
 (14,14,'filipino','Bala ng Pistola','Mga kartutso ng baril na pantulong'),
 (15,15,'filipino','Mga Shell ng Shotgun','Mga bala ng smoothbore shotgun'),
 (16,16,'filipino','Espesyal na Bala','Mga bala na tumatarak, tracer, at match'),
 (17,17,'filipino','Basa na Operasyon','Mga direktang aksyon at kontrata ng pagpapaalis'),
 (18,18,'filipino','Operasyon sa Site','Paglilinis ng lokasyon at pagtatapon ng ebidensya'),
 (19,19,'filipino','Ligtas na Paghahatid','Patago at ligtas na transportasyon ng item'),
 (20,20,'filipino','Mga Optiko','Mga scope, red dot, at magnifier'),
 (21,21,'filipino','Mga Suppressor','Mga panlayo ng tunog at flash'),
 (22,22,'filipino','Mga Grip at Stock','Mga ergonomikong grip at stock'),
 (23,1,'japanese','ライフル','肩撃ち用長銃身の銃器'),
 (24,2,'japanese','ピストル','短銃身のサイドアーム'),
 (25,3,'japanese','ショットガン','スムースボア肩撃ち銃'),
 (26,4,'japanese','サブマシンガン','コンパクトな自動小火器'),
 (27,5,'japanese','マシンガン','ベルトまたはマガジン給弾の自動火器'),
 (28,6,'japanese','スナイパーライフル','長距離精密射撃用ライフル'),
 (29,7,'japanese','剣','両手用長刃武器'),
 (30,8,'japanese','ナイフ','短い片刃または両刃の刃物'),
 (31,9,'japanese','ダガー','両刃の刺し武器'),
 (32,10,'japanese','フォールディングナイフ','ポケット・アシスト折りたたみナイフ'),
 (33,11,'japanese','バトン','警察・戦術打撃棒'),
 (34,12,'japanese','クラブ','重い打撃武器'),
 (35,13,'japanese','ライフル弾','センターファイアライフルカートリッジ'),
 (36,14,'japanese','ピストル弾','ハンドガンカートリッジ'),
 (37,15,'japanese','ショットガンシェル','スムースボアショットガン弾薬'),
 (38,16,'japanese','特殊弾薬','徹甲・トレーサー・マッチ弾'),
 (39,17,'japanese','湿式作戦','直接行動および暗殺契約'),
 (40,18,'japanese','現場作戦','現場清掃および証拠処理'),
 (41,19,'japanese','安全配達','隠密かつ安全な物品輸送'),
 (42,20,'japanese','光学機器','スコープ、レッドドット、マグニファイア'),
 (43,21,'japanese','サプレッサー','消音・消炎装置'),
 (44,22,'japanese','グリップ＆ストック','人間工学的グリップとストック'),
 (45,1,'spanish','Rifles','Armas de fuego de hombro con cañón largo'),
 (46,2,'spanish','Pistolas','Armas cortas secundarias'),
 (47,3,'spanish','Escopetas','Armas de hombro de cañón liso'),
 (48,4,'spanish','Subfusiles','Armas automáticas compactas'),
 (49,5,'spanish','Ametralladoras','Armas automáticas de cinta o cargador'),
 (50,6,'spanish','Rifles de Francotirador','Rifles de precisión de largo alcance'),
 (51,7,'spanish','Espadas','Armas de hoja larga para dos manos'),
 (52,8,'spanish','Cuchillos','Hojas cortas de uno o dos filos'),
 (53,9,'spanish','Dagas','Armas de doble filo para apuñalar'),
 (54,10,'spanish','Navajas','Navajas de bolsillo y asistidas'),
 (55,11,'spanish','Bastones','Palos de golpe policiales y tácticos'),
 (56,12,'spanish','Porras','Armas de impacto pesadas'),
 (57,13,'spanish','Munición para Rifle','Cartuchos de rifle de percusión central'),
 (58,14,'spanish','Munición para Pistola','Cartuchos para pistola'),
 (59,15,'spanish','Cartuchos de Escopeta','Munición para escopeta de cañón liso'),
 (60,16,'spanish','Munición Especial','Balas perforantes, trazadoras y de competición'),
 (61,17,'spanish','Operaciones Húmedas','Contratos de acción directa y eliminación'),
 (62,18,'spanish','Operaciones en Sitio','Limpieza de ubicación y eliminación de evidencia'),
 (63,19,'spanish','Entrega Segura','Transporte encubierto y seguro de artículos'),
 (64,20,'spanish','Óptica','Miras, puntos rojos y magnificadores'),
 (65,21,'spanish','Silenciadores','Supresores de sonido y flash'),
 (66,22,'spanish','Empuñaduras y Culatas','Opciones ergonómicas de empuñadura y culata'),
 (67,1,'mandarin','步枪','肩扛长管枪械'),
 (68,2,'mandarin','手枪','短管副武器'),
 (69,3,'mandarin','霰弹枪','滑膛肩扛枪'),
 (70,4,'mandarin','冲锋枪','紧凑型自动火器'),
 (71,5,'mandarin','机枪','弹链或弹匣供弹的自动武器'),
 (72,6,'mandarin','狙击步枪','远程精准步枪'),
 (73,7,'mandarin','剑','双手长刃武器'),
 (74,8,'mandarin','刀','单刃或双刃短刀'),
 (75,9,'mandarin','匕首','双刃刺击武器'),
 (76,10,'mandarin','折叠刀','口袋刀和辅助开刀'),
 (77,11,'mandarin','警棍','警察和战术打击棍'),
 (78,12,'mandarin','棍棒','重型冲击武器'),
 (79,13,'mandarin','步枪弹','中心发火步枪弹药'),
 (80,14,'mandarin','手枪弹','手枪弹药'),
 (81,15,'mandarin','霰弹枪弹','滑膛霰弹枪弹药'),
 (82,16,'mandarin','特种弹药','穿甲弹、曳光弹和比赛弹'),
 (83,17,'mandarin','湿性行动','直接行动和消除合同'),
 (84,18,'mandarin','现场行动','现场清理和证据处置'),
 (85,19,'mandarin','安全配送','隐秘和安全的物品运输'),
 (86,20,'mandarin','光学设备','瞄准镜、红点和放大器'),
 (87,21,'mandarin','消声器','消音和消焰装置'),
 (88,22,'mandarin','握把和枪托','人体工学握把和枪托选项');
INSERT INTO "users" ("id","username","email","password_hash","role","created_at","updated_at") VALUES (1,'spongebob','spongebob@bikini.bottom','scrypt:32768:8:1$SbTwSrAmCehypPz8$1fd49b243228a73c60f77f4fd51cf7f46d77f044b2576a24fe7de1800ca3dabe891e693f64f2276ef392437527659822711cb089f651944ef50073f5188a0c42','customer','2026-04-15 05:03:32','2026-04-15 05:03:32'),
 (2,'mrcrabs','eugene.crabs@thekrustykrab.com','scrypt:32768:8:1$83oDsOSmvXx89UZx$c0e15772d19273f1df094dffa5fb9846afa2be3bfa47bb50a89d3ec80c57032db06799f09fb4b4d51be28dfb33de4148c29c7b97396f1dbbaba90920d6b78dc3','admin','2026-04-15 05:03:32','2026-04-15 05:03:32'),
 (5,'KelsenGile','kelsengilesarmientoconel@gmail.com','scrypt:32768:8:1$XrzCLf0eixrrKiHF$94eee8816393d6c3fde4901ccd40f36f33d5fed9031cf15212b3a3acc91d25a7b11b7f9295ade278f201088b7c0e87f1242b859b5fc2008aaba577a9d9babdd2','customer','2026-04-15 07:00:44','2026-04-15 07:00:44');
DROP INDEX IF EXISTS "idx_order_items_order";
CREATE INDEX idx_order_items_order  ON order_items (order_id);
DROP INDEX IF EXISTS "idx_orders_status";
CREATE INDEX idx_orders_status      ON orders (status);
DROP INDEX IF EXISTS "idx_orders_user";
CREATE INDEX idx_orders_user        ON orders (user_id);
DROP INDEX IF EXISTS "idx_products_brand";
CREATE INDEX idx_products_brand     ON products (brand_id);
DROP INDEX IF EXISTS "idx_products_category";
CREATE INDEX idx_products_category  ON products (category_id);
DROP INDEX IF EXISTS "idx_products_subcat";
CREATE INDEX idx_products_subcat    ON products (subcategory_id);
DROP INDEX IF EXISTS "idx_services_brand";
CREATE INDEX idx_services_brand     ON services (brand_id);
DROP INDEX IF EXISTS "idx_services_category";
CREATE INDEX idx_services_category  ON services (category_id);
DROP INDEX IF EXISTS "idx_services_subcat";
CREATE INDEX idx_services_subcat    ON services (subcategory_id);
DROP INDEX IF EXISTS "idx_subcats_category";
CREATE INDEX idx_subcats_category   ON subcategories (category_id);
DROP INDEX IF EXISTS "idx_ui_strings_lang";
CREATE INDEX idx_ui_strings_lang ON ui_strings (lang_code);
DROP TRIGGER IF EXISTS "trg_order_completed";
CREATE TRIGGER trg_order_completed
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
DROP TRIGGER IF EXISTS "trg_order_uncompleted";
CREATE TRIGGER trg_order_uncompleted
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
COMMIT;
