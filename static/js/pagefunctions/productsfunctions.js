document.addEventListener("DOMContentLoaded", function () {
    initializeProductsPage();
});

function initializeProductsPage() {
    const toggleButtons = document.querySelectorAll(".toggle-btn");
    const filterButtons = document.querySelectorAll(".filter-btn");

    let savedType = localStorage.getItem("selectedType") || "weapons";
    let savedFilter = localStorage.getItem("selectedFilter") || null;

    toggleButtons.forEach((button) => {
        if (button.dataset.type === savedType) button.classList.add("active");

        button.addEventListener("click", () => {
            toggleButtons.forEach((btn) => btn.classList.remove("active"));
            button.classList.add("active");
            localStorage.setItem("selectedType", button.dataset.type);
            updateHeroType(button.dataset.type);
            updateProductsSelection();
        });
    });

    filterButtons.forEach((button) => {
        if (button.dataset.filter === savedFilter) button.classList.add("active");

        button.addEventListener("click", () => {
            filterButtons.forEach((btn) => btn.classList.remove("active"));
            button.classList.add("active");
            localStorage.setItem("selectedFilter", button.dataset.filter);
            updateProductsSelection();
        });
    });

    // Default to first filter if none saved
    if (!savedFilter && filterButtons.length > 0) {
        filterButtons[0].classList.add("active");
        localStorage.setItem("selectedFilter", filterButtons[0].dataset.filter);
    }

    updateHeroType(savedType);
    updateProductsSelection();
}

function updateHeroType(type) {
    const heroTitle = document.querySelector(".hero-sign-title");
    if (heroTitle) heroTitle.textContent = type.toUpperCase();
}

function updateProductsSelection() {
    const activeTypeButton = document.querySelector(".toggle-btn.active");
    const activeFilterButton = document.querySelector(".filter-btn.active");
    const selectionContent = document.getElementById("selection-content");
    const selectionTitle = document.getElementById("selection-title");

    if (!activeTypeButton || !activeFilterButton || !selectionContent || !selectionTitle) return;

    const type = activeTypeButton.dataset.type;
    const filter = activeFilterButton.dataset.filter;

    const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);
    selectionTitle.textContent = `${cap(type)} · ${cap(filter)}`;

    // Pull content from the matching <template id="panel-{type}-{filter}"> in the HTML
    const template = document.getElementById(`panel-${type}-${filter}`);

    selectionContent.style.opacity = "0";
    selectionContent.style.transform = "translateY(6px)";

    requestAnimationFrame(() => {
        if (template) {
            selectionContent.replaceChildren(template.content.cloneNode(true));
        } else {
            selectionContent.innerHTML = `<p class="selection-status">No content yet for ${cap(type)} › ${cap(filter)}.</p>`;
        }

        requestAnimationFrame(() => {
            selectionContent.style.transition = "opacity 0.2s ease, transform 0.2s ease";
            selectionContent.style.opacity = "1";
            selectionContent.style.transform = "translateY(0)";
        });
    });
}