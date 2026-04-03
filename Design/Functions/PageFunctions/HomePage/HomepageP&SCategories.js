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

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    setupCategoryButtons();
    setupScrollListeners();
    renderCategory(currentCategory);
});