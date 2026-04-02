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


function initCarousel(section, data) {
    const wrapperEl = document.querySelector(`.carousel-wrapper[data-section="${section}"]`);
    const trackEl = wrapperEl.querySelector(`.carousel-track[data-section="${section}"]`);

    let isScrolling = false;
    let direction = 1; // 1 = right, -1 = left
    let autoScrollId = null;
    let resetTimeoutId = null;

    // Create category rectangles with images and labels
    data.forEach((item, index) => {
        const card = document.createElement('div');
        card.className = 'category-rect';
        card.dataset.index = index;
        card.dataset.name = item.name;

        // Create image container
        const imageDiv = document.createElement('div');
        imageDiv.className = 'category-image';

        const img = document.createElement('img');
        img.src = item.image;
        img.alt = item.name;
        imageDiv.appendChild(img);

        // Create label
        const label = document.createElement('div');
        label.className = 'category-label';
        label.textContent = item.name;

        // Append to card
        card.appendChild(imageDiv);
        card.appendChild(label);
        trackEl.appendChild(card);
    });

    function getMaxScroll() {
        return trackEl.scrollWidth - wrapperEl.clientWidth;
    }

    function startAutoScroll() {
        clearInterval(autoScrollId);
        clearTimeout(resetTimeoutId);

        let scrollSpeed = 1.5; // pixels per interval
        autoScrollId = setInterval(() => {
            const currentScroll = wrapperEl.scrollLeft;
            const maxScroll = getMaxScroll();

            let newScroll = currentScroll + scrollSpeed * direction;

            // Reverse direction at boundaries
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

    // Stop auto-scroll when user scrolls
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
            }, 3000); // Resume after 3 seconds of no scroll
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

    // Card click - with page navigation
    trackEl.querySelectorAll('.category-rect').forEach(card => {
        card.addEventListener('click', (e) => {
            const categoryName = card.dataset.name;
            const targetPage = categoryPageMap[categoryName];

            // Update active state
            trackEl.querySelectorAll('.category-rect').forEach(c => c.classList.remove('active'));
            card.classList.add('active');

            // Navigate to page if mapping exists
            if (targetPage) {
                window.location.href = targetPage;
            } else {
                console.warn(`No page mapping found for: ${categoryName}`);
            }
        });
    });

    // Initialize
    startAutoScroll();
}

// Initialize all carousels
initCarousel('weapons', carouselData.weapons);
initCarousel('equipment', carouselData.equipment);
initCarousel('services', carouselData.services);