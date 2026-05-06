// ───────────────────────────────────────────────────────────────────────────── //
//     SETTINGS PANEL FUNCTIONS
// ───────────────────────────────────────────────────────────────────────────── //

/* ── Element refs ───────────────────────────────────────────── */
const overlay = document.getElementById("settingsOverlay");
const sidebar = document.getElementById("settingsSidebar");
const closeBtn = document.getElementById("settingsClose");
const openBtn = document.getElementById("settingsOpenBtn");

/* ── Open / close ───────────────────────────────────────────── */
function openSettings() {
    overlay.classList.add("active");
    sidebar.classList.add("open");
}

function closeSettings() {
    overlay.classList.remove("active");
    sidebar.classList.remove("open");
}

openBtn.addEventListener("click", openSettings);
closeBtn.addEventListener("click", closeSettings);
overlay.addEventListener("click", closeSettings);

/* ── Escape key ─────────────────────────────────────────────── */
document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeSettings();
});

/* ── Nav item clicks — navigate to settings page with section ── */
sidebar.querySelectorAll(".set-item[data-section]").forEach(link => {
    link.addEventListener("click", function (e) {
        // The href already carries ?section=..., so let normal navigation happen.
        // This handler just closes the sidebar first for a clean UX if you ever
        // want to intercept (e.g. same-page SPA behaviour). Remove the two lines
        // below if you prefer a full page navigation without closing first.
        closeSettings();
        // Allow the <a> href to navigate normally — do NOT call e.preventDefault().
    });
});