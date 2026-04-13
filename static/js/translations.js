

/* ──────────────────────────────────────────────────────────────────────────
    //     TRANSLATIONS
    // ───────────────────────────────────────────────────────────────────────────── */

const translations = {
    english: {
        settings: "Settings",
        preferences: "Preferences",
        account: "Account",
        appearance: "Appearance",
        notifications: "Notifications",
        privacy_security: "Privacy & Security",
        general: "General",
        language_region: "Language & Region",
        help_support: "Help & Support",
        advanced: "Advanced",
        system_actions: "System Actions",
        secure_connection: "Secure Connection",
        about: "About",
        contacts: "Contacts",
        legal: "Legal",
        companyname: "ArmsDealer",
        class: "Tactical Supply Co.",
        products: "Products",
        services: "Services",
        search: "Search",
        cart: "Cart",

        // Homepage Translations
        slide1heropagetitle: "Precision"
    },

    filipino: {
        settings: "Mga Setting",
        preferences: "Mga Kagustuhan",
        account: "Account",
        appearance: "Hitsura",
        notifications: "Mga Abiso",
        privacy_security: "Pagkapribado at Seguridad",
        general: "Pangkalahatan",
        language_region: "Wika at Rehiyon",
        help_support: "Tulong at Suporta",
        advanced: "Advanced",
        system_actions: "Mga Aksyon ng Sistema",
        secure_connection: "Ligtas na Koneksyon",
        about: "Tungkol",
        contacts: "Mga Kontak",
        legal: "Legal",
        companyname: "ArmsDealer",
        class: "Kumpanyang Suplay Taktikal",
        products: "Mga Produkto",
        services: "Mga Serbisyo",
        search: "Maghanap",
        cart: "Kariton",

        // Homepage Translations
        slide1heropagetitle: "Presisyon"
    },

    japanese: {
        settings: "設定",
        preferences: "設定項目",
        account: "アカウント",
        appearance: "外観",
        notifications: "通知",
        privacy_security: "プライバシーとセキュリティ",
        general: "一般",
        language_region: "言語と地域",
        help_support: "ヘルプとサポート",
        advanced: "詳細設定",
        system_actions: "システム操作",
        secure_connection: "安全な接続",
        about: "概要",
        contacts: "連絡先",
        legal: "法的情報",
        companyname: "ArmsDealer",
        class: "タクティカルサプライ社",
        products: "製品",
        services: "サービス",
        search: "検索",
        cart: "カート",

        // Homepage Translations
        slide1heropagetitle: "精密"
    },

    spanish: {
        settings: "Configuración",
        preferences: "Preferencias",
        account: "Cuenta",
        appearance: "Apariencia",
        notifications: "Notificaciones",
        privacy_security: "Privacidad y Seguridad",
        general: "General",
        language_region: "Idioma y Región",
        help_support: "Ayuda y Soporte",
        advanced: "Avanzado",
        system_actions: "Acciones del Sistema",
        secure_connection: "Conexión Segura",
        about: "Acerca de",
        contacts: "Contactos",
        legal: "Legal",
        companyname: "ArmsDealer",
        class: "Compañía de Suministros Tácticos",
        products: "Productos",
        services: "Servicios",
        search: "Buscar",
        cart: "Carrito",

        // Homepage Translations
        slide1heropagetitle: "Precisión"
    },

    mandarin: {
        settings: "设置",
        preferences: "偏好",
        account: "账户",
        appearance: "外观",
        notifications: "通知",
        privacy_security: "隐私与安全",
        general: "常规",
        language_region: "语言和地区",
        help_support: "帮助与支持",
        advanced: "高级",
        system_actions: "系统操作",
        secure_connection: "安全连接",
        about: "关于",
        contacts: "联系方式",
        legal: "法律",
        companyname: "ArmsDealer",
        class: "战术供应公司",
        products: "产品",
        services: "服务",
        search: "搜索",
        cart: "购物车",

        // Homepage Translations
        slide1heropagetitle: "精准"
    }
};

function setLanguage(lang) {
    const elements = document.querySelectorAll("[data-translate]");

    elements.forEach(el => {
        const key = el.getAttribute("data-translate");

        el.textContent =
            translations[lang]?.[key] ||
            translations["english"][key] ||
            key;
    });

    localStorage.setItem("lang", lang);
}


window.setLanguage = setLanguage;

document.addEventListener("DOMContentLoaded", () => {
    const savedLang = localStorage.getItem("lang") || "english";

    setLanguage(savedLang);

    const select = document.getElementById("languageSelect");
    if (select) select.value = savedLang;
});