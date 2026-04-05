/**
 * ========================================
 * COMBINED JAVASCRIPT - COMPLETE
 * ========================================
 * All sections organized with variable names tracked
 */

// ===========================================
// SECTION 1: HERO CAROUSEL
// ===========================================
(function () {
    const carousel = document.getElementById('heroCarousel');
    const slides = carousel.querySelectorAll('.hero-slide');
    const dotsWrap = document.getElementById('heroDots');
    const counter = document.getElementById('heroCurrentNum');
    const prevBtn = document.getElementById('heroPrev');
    const nextBtn = document.getElementById('heroNext');

    let current = 0;
    let animating = false;
    let autoTimer = null;
    const TOTAL = slides.length;
    const DELAY = 10000; // ms between auto-advances

    /* ── Build dot indicators ─────────────────────────────── */
    slides.forEach((_, i) => {
        const dot = document.createElement('button');
        dot.className = 'hero-dot' + (i === 0 ? ' active' : '');
        dot.setAttribute('aria-label', `Go to slide ${i + 1}`);
        dot.addEventListener('click', () => goTo(i, i > current ? 'right' : 'left'));
        dotsWrap.appendChild(dot);
    });

    const dots = dotsWrap.querySelectorAll('.hero-dot');

    /* ── Text elements selector ───────────────────────────── */
    const TEXT_SELECTORS = '.hero-tag, .hero-title, .hero-subtitle, .hero-cta';

    /* Hard-reset text children so CSS transitions re-fire every time */
    function resetTextChildren(slide) {
        slide.querySelectorAll(TEXT_SELECTORS).forEach(el => {
            el.style.transition = 'none';
            el.style.opacity = '0';
            el.style.transform = 'translateY(14px)';
        });
        /* Force reflow so the reset is painted before restoring transitions */
        void slide.offsetHeight;
        slide.querySelectorAll(TEXT_SELECTORS).forEach(el => {
            el.style.transition = '';
            el.style.opacity = '';
            el.style.transform = '';
        });
    }

    /* ── Core transition ──────────────────────────────────── */
    function goTo(next, direction) {
        if (animating || next === current) return;
        animating = true;

        const outSlide = slides[current];
        const inSlide = slides[next];

        /* 1. Remove active from outgoing slide */
        outSlide.classList.remove('active');

        /* 2. Force-reset text children on the incoming slide BEFORE
              adding .active, so CSS transitions see a real 0→1 change */
        resetTextChildren(inSlide);

        /* 3. Position incoming slide off-screen with no transition */
        inSlide.style.transition = 'none';
        inSlide.style.opacity = '0';
        inSlide.style.transform = direction === 'right'
            ? 'translateX(60px) scale(1.04)'
            : 'translateX(-60px) scale(1.04)';

        /* 4. Force reflow */
        void inSlide.offsetHeight;

        /* 5. Restore transition and activate */
        inSlide.style.transition = '';
        inSlide.style.opacity = '';
        inSlide.style.transform = '';
        inSlide.classList.add('active');

        /* Update dots & counter */
        dots[current].classList.remove('active');
        dots[next].classList.add('active');
        counter.textContent = String(next + 1).padStart(2, '0');

        current = next;

        /* Unlock after transition completes */
        setTimeout(() => { animating = false; }, 850);

        resetAuto();
    }

    function goPrev() { goTo((current - 1 + TOTAL) % TOTAL, 'left'); }
    function goNext() { goTo((current + 1) % TOTAL, 'right'); }

    prevBtn.addEventListener('click', goPrev);
    nextBtn.addEventListener('click', goNext);

    /* ── Auto-advance ─────────────────────────────────────── */
    function startAuto() { autoTimer = setInterval(goNext, DELAY); }
    function resetAuto() { clearInterval(autoTimer); startAuto(); }

    startAuto();

    /* ── Pause on hover ───────────────────────────────────── */
    carousel.addEventListener('mouseenter', () => clearInterval(autoTimer));
    carousel.addEventListener('mouseleave', startAuto);

    /* ── Keyboard support ─────────────────────────────────── */
    document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft') goPrev();
        if (e.key === 'ArrowRight') goNext();
    });

    /* ── Touch / swipe support ────────────────────────────── */
    let touchStartX = 0;
    carousel.addEventListener('touchstart', (e) => {
        touchStartX = e.changedTouches[0].clientX;
    }, { passive: true });
    carousel.addEventListener('touchend', (e) => {
        const dx = e.changedTouches[0].clientX - touchStartX;
        if (Math.abs(dx) > 40) dx < 0 ? goNext() : goPrev();
    }, { passive: true });

})();


// ===========================================
// SECTION 2: CAROUSEL DATA & CATEGORY MAP
// ===========================================
const carouselData = {
    weapons: [
        { name: 'Firearms', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Blades', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Blunts', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Projectile', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Explosives', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Electronic', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Chemical', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Biological', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Vehicle', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Cyber', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Security', image: '../../../Assets/Images/ArmsDealerLogo.png' }
    ],
    equipment: [
        { name: 'Ammunition', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Protective', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Tactical', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Attachments', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Maintenance', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Storage', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Cases', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Communication', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Survival', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Training', image: '../../../Assets/Images/ArmsDealerLogo.png' }
    ],
    services: [
        { name: 'Manufacturing', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Customization', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Maintenance', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Transport', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Storage', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Training', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Protection', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Consulting', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Research', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Testing', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Disposal', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Surveillance', image: '../../../Assets/Images/ArmsDealerLogo.png' },
        { name: 'Contracting', image: '../../../Assets/Images/ArmsDealerLogo.png' }
    ]
};

const categoryPageMap = {
    // WEAPONS CATEGORIES
    'Firearms': '/pages/products/firearms.html',
    'Blades': '/pages/products/blades.html',
    'Blunts': '/pages/products/blunts.html',
    'Projectile': '/pages/products/projectile.html',
    'Explosives': '/pages/products/explosives.html',
    'Electronic': '/pages/products/electronic.html',
    'Chemical': '/pages/products/chemical.html',
    'Biological': '/pages/products/biological.html',
    'Vehicle': '/pages/products/vehicle.html',
    'Cyber': '/pages/products/cyber.html',
    'Security': '/pages/products/security.html',

    // EQUIPMENT CATEGORIES
    'Ammunition': '/pages/products/ammunition.html',
    'Protective': '/pages/products/protective.html',
    'Tactical': '/pages/products/tactical.html',
    'Attachments': '/pages/products/attachments.html',
    'Maintenance': '/pages/products/maintenance.html',
    'Storage': '/pages/products/storage.html',
    'Cases': '/pages/products/cases.html',
    'Communication': '/pages/products/communication.html',
    'Survival': '/pages/products/survival.html',
    'Training': '/pages/products/training.html',

    // SERVICES CATEGORIES
    'Manufacturing': '/pages/services/manufacturing.html',
    'Customization': '/pages/services/customization.html',
    'Maintenance': '/pages/services/maintenance.html',
    'Transport': '/pages/services/transport.html',
    'Storage': '/pages/services/storage.html',
    'Training': '/pages/services/training.html',
    'Protection': '/pages/services/protection.html',
    'Consulting': '/pages/services/consulting.html',
    'Research': '/pages/services/research.html',
    'Testing': '/pages/services/testing.html',
    'Disposal': '/pages/services/disposal.html',
    'Surveillance': '/pages/services/surveillance.html',
    'Contracting': '/pages/services/contracting.html'
};


// ===========================================
// SECTION 3: CATEGORY CAROUSEL FUNCTIONS
// ===========================================
let currentCategory = 'weapons';
let autoScrollId = null;
let resetTimeoutId = null;
let isScrolling = false;
let direction = 1; // 1 = right, -1 = left

function getWrapperEl() {
    return document.querySelector('.carousel-wrapper');
}

function getTrackEl() {
    return document.querySelector('.carousel-track');
}

function getMaxScroll() {
    const wrapperEl = getWrapperEl();
    const trackEl = getTrackEl();
    return trackEl.scrollWidth - wrapperEl.clientWidth;
}

function startAutoScroll() {
    clearInterval(autoScrollId);
    clearTimeout(resetTimeoutId);

    let scrollSpeed = 1.5;
    const wrapperEl = getWrapperEl();

    autoScrollId = setInterval(() => {
        const currentScroll = wrapperEl.scrollLeft;
        const maxScroll = getMaxScroll();

        let newScroll = currentScroll + scrollSpeed * direction;

        if (newScroll >= maxScroll) {
            newScroll = maxScroll;
            direction = -1;
        } else if (newScroll <= 0) {
            newScroll = 0;
            direction = 1;
        }

        wrapperEl.scrollLeft = newScroll;
    }, 30);
}

function stopAutoScroll() {
    clearInterval(autoScrollId);
    clearTimeout(resetTimeoutId);
}

function renderCategory(categoryName) {
    const wrapperEl = getWrapperEl();
    const trackEl = getTrackEl();
    const data = carouselData[categoryName];

    // Clear existing cards
    trackEl.innerHTML = '';

    // Create new cards for the selected category
    data.forEach((item, index) => {
        const card = document.createElement('div');
        card.className = 'category-rect';
        card.dataset.index = index;
        card.dataset.name = item.name;

        const imageDiv = document.createElement('div');
        imageDiv.className = 'category-image';

        const img = document.createElement('img');
        img.src = item.image;
        img.alt = item.name;
        imageDiv.appendChild(img);

        const label = document.createElement('div');
        label.className = 'category-label';
        label.textContent = item.name;

        card.appendChild(imageDiv);
        card.appendChild(label);
        trackEl.appendChild(card);

        // Add click handler
        card.addEventListener('click', (e) => {
            const categoryName = card.dataset.name;
            const targetPage = categoryPageMap[categoryName];

            trackEl.querySelectorAll('.category-rect').forEach(c => c.classList.remove('active'));
            card.classList.add('active');

            if (targetPage) {
                window.location.href = targetPage;
            } else {
                console.warn(`No page mapping found for: ${categoryName}`);
            }
        });
    });

    // Reset scroll position
    wrapperEl.scrollLeft = 0;
    direction = 1;
    isScrolling = false;

    // Restart auto scroll
    startAutoScroll();
}

function setupCategoryButtons() {
    const buttonContainer = document.querySelector('.category-buttons');
    if (!buttonContainer) return;

    ['Weapons', 'Equipment', 'Services'].forEach((label) => {
        const button = document.createElement('button');
        button.className = 'category-btn';
        button.textContent = label;
        button.dataset.category = label.toLowerCase();

        if (label.toLowerCase() === currentCategory) {
            button.classList.add('active');
        }

        button.addEventListener('click', () => {
            const categoryName = button.dataset.category;

            // Update active button
            document.querySelectorAll('.category-btn').forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');

            // Update category and render
            currentCategory = categoryName;
            renderCategory(categoryName);
        });

        buttonContainer.appendChild(button);
    });
}

function setupScrollListeners() {
    const wrapperEl = getWrapperEl();
    const trackEl = getTrackEl();

    wrapperEl.addEventListener('mousedown', () => {
        isScrolling = true;
        stopAutoScroll();
    });

    wrapperEl.addEventListener('wheel', (e) => {
        isScrolling = true;
        stopAutoScroll();
    }, { passive: true });

    wrapperEl.addEventListener('scroll', () => {
        if (isScrolling) {
            clearTimeout(resetTimeoutId);
            resetTimeoutId = setTimeout(() => {
                isScrolling = false;
                startAutoScroll();
            }, 3000);
        }
    });

    wrapperEl.addEventListener('mouseup', () => {
        isScrolling = false;
    });

    wrapperEl.addEventListener('mouseleave', () => {
        if (isScrolling) {
            isScrolling = false;
            resetTimeoutId = setTimeout(() => {
                startAutoScroll();
            }, 3000);
        }
    });
}


// ===========================================
// SECTION 4: SMOOTH SCROLL & CTA HANDLERS
// ===========================================
/**
 * Smooth scroll behavior for anchor links
 */
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        } else {
            console.log('Navigate to: ' + this.getAttribute('href'));
        }
    });
});

/**
 * CTA Button Handler
 */
function handleCTA(action) {
    console.log('User clicked: ' + action);
    // Replace with your actual navigation logic
    if (action === 'create account') {
        alert('Redirecting to product catalog...');
    }
}


// ===========================================
// SECTION 5: INTERSECTION OBSERVER (SCROLL ANIMATION)
// ===========================================
/**
 * Add subtle animation to trust cards on scroll
 */
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver(function (entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe elements for lazy animation
document.querySelectorAll('.trust-card, .process-step').forEach(el => {
    el.style.opacity = '0.95'; // Ensure visibility
    observer.observe(el);
});


// ===========================================
// SECTION 6: HOVER EFFECTS & Z-INDEX
// ===========================================
/**
 * Add hover effects to interactive elements
 */
document.querySelectorAll('.cta-btn, .trust-card, .process-step').forEach(element => {
    element.addEventListener('mouseenter', function () {
        // Optional: Add subtle feedback here
        this.style.zIndex = '100';
    });
    element.addEventListener('mouseleave', function () {
        this.style.zIndex = '1';
    });
});


// ===========================================
// SECTION 7: FEATURED CAROUSEL (FC)
// ===========================================
(function () {
    const pages = Array.from(document.querySelectorAll('.fc-page'));
    const dotsWrap = document.getElementById('fcDots');
    const pageLabel = document.getElementById('fcPageLabel');
    let cur = 0;

    pages.forEach((p, i) => {
        const dot = document.createElement('div');
        dot.className = 'fc-dot' + (i === 0 ? ' active' : '');
        const label = document.createElement('div');
        label.className = 'fc-dot-label';
        label.textContent = p.dataset.label || ('Page ' + (i + 1));
        dot.appendChild(label);
        dot.addEventListener('click', () => fcGo(i));
        dotsWrap.appendChild(dot);
    });

    const dots = dotsWrap.querySelectorAll('.fc-dot');

    function fcGo(n) {
        pages[cur].classList.remove('active');
        dots[cur].classList.remove('active');
        cur = (n + pages.length) % pages.length;
        pages[cur].classList.add('active');
        dots[cur].classList.add('active');
        pageLabel.textContent = pages[cur].dataset.label || ('Page ' + (cur + 1));
    }

    document.getElementById('fcPrev').addEventListener('click', () => fcGo(cur - 1));
    document.getElementById('fcNext').addEventListener('click', () => fcGo(cur + 1));

    document.addEventListener('keydown', e => {
        if (e.key === 'ArrowLeft') fcGo(cur - 1);
        if (e.key === 'ArrowRight') fcGo(cur + 1);
    });

    document.querySelectorAll('.fc-card').forEach(card => {
        const popup = card.querySelector('.fc-popup');
        if (!popup) return;

        card.addEventListener('mouseenter', function () {
            const data = JSON.parse(this.dataset.popup || '{}');
            if (!data.name) return;

            popup.querySelector('.fc-popup-name').textContent = data.name;
            popup.querySelector('.fc-popup-desc').textContent = data.desc;
            const tagsEl = popup.querySelector('.fc-popup-tags');
            tagsEl.innerHTML = '';
            (data.tags || []).forEach(t => {
                const span = document.createElement('span');
                span.className = 'fc-popup-tag';
                span.textContent = t;
                tagsEl.appendChild(span);
            });

            // Use card's viewport position to decide pop direction
            const rect = this.getBoundingClientRect();
            this.classList.toggle('pop-left', rect.left + rect.width / 2 > window.innerWidth / 2);
            this.classList.toggle('pop-up', rect.top + rect.height / 2 > window.innerHeight / 2);

            popup.style.display = 'block';
        });

        card.addEventListener('mouseleave', function () {
            popup.style.display = 'none';
        });
    });
})();


// ===========================================
// SECTION 8: INITIALIZATION
// ===========================================
/**
 * Initialize category carousel on DOM ready
 */
document.addEventListener('DOMContentLoaded', () => {
    setupCategoryButtons();
    setupScrollListeners();
    renderCategory(currentCategory);
});


// ===========================================
// SECTION 9: DEVELOPER CONSOLE MESSAGE
// ===========================================
/**
 * Console message for developers
 */
console.log('%c Welcome to Armsdealer Website ', 'background: #a8c49a; color: #1a1f1a; padding: 10px; font-size: 16px; font-weight: bold;');
console.log('%c Edit content in the HTML sections above ', 'color: #a8c49a; font-size: 12px;');
console.log('%c All CSS is embedded - no external files needed ', 'color: #a8c49a; font-size: 12px;');

// ════════════════════════════════════════════════════════════
// BUNDLES SECTION LOGIC
// ════════════════════════════════════════════════════════════

const bundlesData = [
    {
        name: 'Seasonal Bundle',
        desc: 'Limited-time curated collection for tactical enthusiasts and professionals',
        fullDesc: 'Experience our premium seasonal collection, carefully curated for those who demand the best. Perfect for operators looking to upgrade their tactical arsenal.',
        timer: '14 days',
        price: 1911,
        oldPrice: 2450,
        discount: '-22%',
        icon: '📦',
        items: [
            { name: 'AR-15 Rifle', price: '₱890', icon: '🔫' },
            { name: 'Ammo (500 rds)', price: '₱450', icon: '💥' },
            { name: 'Tactical Vest', price: '₱650', icon: '🛡️' },
            { name: 'Cleaning Kit', price: '₱460', icon: '🔧' }
        ]
    },
    {
        name: 'Best Value Bundle',
        desc: 'Maximum savings on premium equipment with best-in-class features',
        fullDesc: 'Get more for your money with this incredible value bundle. Premium quality without the premium price tag.',
        timer: '21 days',
        price: 2599,
        oldPrice: 3450,
        discount: '-25%',
        icon: '💎',
        items: [
            { name: 'Glock 17', price: '₱920', icon: '🔫' },
            { name: 'Holster', price: '₱280', icon: '🎯' },
            { name: 'Magazine Set', price: '₱340', icon: '📦' },
            { name: 'Training Manual', price: '₱450', icon: '📖' }
        ]
    },
    {
        name: 'Starter Pack',
        desc: 'Perfect for beginners entering the tactical gear lifestyle',
        fullDesc: 'Your complete introduction to tactical operations. Everything a beginner needs to get started safely and effectively.',
        timer: '7 days',
        price: 1250,
        oldPrice: 1680,
        discount: '-26%',
        icon: '🎯',
        items: [
            { name: 'Basic Pistol', price: '₱680', icon: '🔫' },
            { name: 'Safety Glasses', price: '₱120', icon: '👓' },
            { name: 'Ear Protection', price: '₱180', icon: '🎧' },
            { name: 'Guide Book', price: '₱270', icon: '📚' }
        ]
    },
    {
        name: 'Pro Bundle',
        desc: 'For experienced operators requiring advanced tactical solutions',
        fullDesc: 'Advanced gear for professional operators. Engineered for high-performance tactical situations.',
        timer: '10 days',
        price: 4850,
        oldPrice: 6200,
        discount: '-22%',
        icon: '⚡',
        items: [
            { name: 'Precision Rifle', price: '₱2100', icon: '🎯' },
            { name: 'Advanced Scope', price: '₱1200', icon: '🔭' },
            { name: 'Professional Case', price: '₱800', icon: '📦' },
            { name: 'Maintenance Kit', price: '₱750', icon: '🔧' }
        ]
    },
    {
        name: 'Defense Bundle',
        desc: 'Complete home security and personal protection package',
        fullDesc: 'Comprehensive security solution for your peace of mind. Professional-grade protection for your home and family.',
        timer: '18 days',
        price: 3299,
        oldPrice: 4200,
        discount: '-21%',
        icon: '🛡️',
        items: [
            { name: 'Security System', price: '₱1200', icon: '📡' },
            { name: 'Perimeter Alarm', price: '₱850', icon: '🔔' },
            { name: 'Motion Sensors', price: '₱600', icon: '👁️' },
            { name: 'Control Panel', price: '₱650', icon: '⚙️' }
        ]
    },
    {
        name: 'Travel Bundle',
        desc: 'Compact and portable tactical gear for on-the-go operations',
        fullDesc: 'Everything you need to go tactical on the road. Compact, reliable, and mission-ready.',
        timer: '12 days',
        price: 1799,
        oldPrice: 2350,
        discount: '-23%',
        icon: '🧳',
        items: [
            { name: 'Compact Pistol', price: '₱950', icon: '🔫' },
            { name: 'Travel Case', price: '₱450', icon: '📦' },
            { name: 'Magazine Pouch', price: '₱200', icon: '🎒' },
            { name: 'Carabiner Set', price: '₱200', icon: '⛓️' }
        ]
    }
];

let currentBundleIndex = 0;

function updateBundleDisplay() {
    const bundle = bundlesData[currentBundleIndex];

    // Update labels and content
    document.getElementById('bundleLabel').textContent = bundle.name;
    document.getElementById('bundleTitle').textContent = bundle.name;
    document.getElementById('bundleDesc').textContent = bundle.desc;
    document.getElementById('bundleFullDesc').textContent = bundle.fullDesc;
    document.getElementById('bundleTimerTop').textContent = bundle.timer;
    document.getElementById('bundleTimerBottom').textContent = bundle.timer;
    document.getElementById('bundleProductImage').textContent = bundle.icon;
    document.getElementById('bundleDiscountDisplay').textContent = bundle.discount;
    document.getElementById('bundleOldPriceDisplay').textContent = '₱' + bundle.oldPrice.toLocaleString();
    document.getElementById('bundleNewPriceDisplay').textContent = '₱' + bundle.price.toLocaleString();

    // Update items grid
    const itemsGrid = document.getElementById('bundleItemsGrid');
    itemsGrid.innerHTML = bundle.items.map(item => `
                <div class="bundle-item-card">
                    <div class="bundle-item-image">${item.icon}</div>
                    <div class="bundle-item-label">${item.name}</div>
                    <div class="bundle-item-price-overlay">
                        <div class="bundle-item-name-overlay">${item.name}</div>
                        <div class="bundle-item-price-overlay-text">${item.price}</div>
                    </div>
                </div>
            `).join('');

    document.getElementById('bundleItemsDesc').textContent = bundle.desc + ' - Professional-grade package with everything you need.';

    // Update dots
    document.querySelectorAll('.bundle-dot').forEach((dot, i) => {
        dot.classList.toggle('active', i === currentBundleIndex);
    });
}

function initializeBundles() {
    const dotsWrapper = document.getElementById('bundleDotsWrapper');
    bundlesData.forEach((_, i) => {
        const dot = document.createElement('div');
        dot.className = 'bundle-dot' + (i === 0 ? ' active' : '');
        dot.addEventListener('click', () => {
            currentBundleIndex = i;
            updateBundleDisplay();
        });
        dotsWrapper.appendChild(dot);
    });

    document.getElementById('bundlePrevBtn').addEventListener('click', () => {
        currentBundleIndex = (currentBundleIndex - 1 + bundlesData.length) % bundlesData.length;
        updateBundleDisplay();
    });

    document.getElementById('bundleNextBtn').addEventListener('click', () => {
        currentBundleIndex = (currentBundleIndex + 1) % bundlesData.length;
        updateBundleDisplay();
    });

    updateBundleDisplay();
}

// Initialize on DOM load
document.addEventListener('DOMContentLoaded', () => {
    initializeBundles();
});

// ════════════════════════════════════════════════════════════
// BEST SELLERS SECTION LOGIC
// ════════════════════════════════════════════════════════════

const bestsellersData = {
    weapons: [
        { rank: 1, title: 'M4A1 Carbine', desc: 'Professional tactical rifle trusted by military and law enforcement worldwide.', price: '₱138,750', sold: '3,591', stock: 95, icon: '🎯' },
        { rank: 2, title: 'Glock 17 Gen5', desc: 'Striker-fired duty pistol with proven reliability', price: '₱54,400', sold: '2,847', stock: 72, icon: '🔫' },
        { rank: 3, title: 'Tactical Knife', desc: 'High-grade stainless steel combat blade', price: '₱2,850', sold: '1,923', stock: 58, icon: '⚔️' }
    ],
    equipment: [
        { rank: 1, title: 'Tactical Vest', desc: 'Level IV ballistic protection with MOLLE webbing system', price: '₱33,600', sold: '2,156', stock: 88, icon: '🛡️' },
        { rank: 2, title: 'Combat Helmet', desc: 'NIJ Level IIIA rated with integrated accessories rail', price: '₱8,900', sold: '1,834', stock: 67, icon: '🎖️' },
        { rank: 3, title: 'Magazine Pouch Set', desc: 'Modular rapid-access ammunition storage', price: '₱1,200', sold: '4,521', stock: 92, icon: '📦' }
    ],
    services: [
        { rank: 1, title: 'Gunsmith Overhaul', desc: 'Complete inspection, cleaning, and performance optimization', price: '₱9,600', sold: '1,234', stock: 75, icon: '🔧' },
        { rank: 2, title: 'Custom Cerakote', desc: 'Mil-spec finish in any color or pattern', price: '₱6,400', sold: '856', stock: 48, icon: '🎨' },
        { rank: 3, title: 'Training Course', desc: 'Professional 8-hour tactical firearms certification', price: '₱15,000', sold: '432', stock: 82, icon: '📚' }
    ]
};

function updateBestsellersDisplay(category) {
    const items = bestsellersData[category];

    // Update top 1
    const top = items[0];
    document.getElementById('bestseller1Title').textContent = top.title;
    document.getElementById('bestseller1Desc').textContent = top.desc;
    document.getElementById('bestseller1Price').textContent = top.price;
    document.getElementById('bestseller1Sold').textContent = top.sold;
    document.getElementById('bestseller1StockBar').style.width = top.stock + '%';
    document.getElementById('bestseller1StockInfo').textContent = top.stock + '% sold - ' + (top.stock === 100 ? 'Out of stock' : 'Limited stock remaining');
    document.querySelector('.bestseller-top-one-image span').textContent = top.icon;

    // Update bottom 2
    const cards = document.querySelectorAll('.bestseller-card');
    [1, 2].forEach((idx) => {
        const item = items[idx];
        const card = cards[idx - 1];
        card.querySelector('.bestseller-card-title').textContent = item.title;
        card.querySelector('.bestseller-card-desc').textContent = item.desc;
        card.querySelector('.bestseller-card-price-value').textContent = item.price;
        card.querySelector('.bestseller-card-sold').textContent = item.sold + ' sold';
        card.querySelector('.bestseller-card-mini-bar-fill').style.width = item.stock + '%';
        card.querySelector('.bestseller-card-image span').textContent = item.icon;
    });

    // Update table
    const tableBody = document.getElementById('tableBody');
    tableBody.innerHTML = items.map(item => `
                <tr>
                    <td class="bestseller-table-rank">${item.rank}</td>
                    <td>${item.title}</td>
                    <td>${item.price}</td>
                    <td>${item.sold}</td>
                </tr>
            `).join('');
}

function initializeBestsellers() {
    const categoryButtons = document.querySelectorAll('.category-btn');
    categoryButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            categoryButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            updateBestsellersDisplay(btn.dataset.category);
        });
    });

    const tableToggle = document.getElementById('tableToggle');
    const tableContent = document.getElementById('tableContent');
    tableToggle.addEventListener('click', () => {
        tableToggle.classList.toggle('active');
        tableContent.classList.toggle('active');
        tableToggle.querySelector('span:last-child').style.transform = tableContent.classList.contains('active') ? 'rotate(180deg)' : 'rotate(0)';
    });

    updateBestsellersDisplay('weapons');
}

// ════════════════════════════════════════════════════════════
// INITIALIZE ON DOM LOAD
// ════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    initializeBestsellers();
});