/* ──────────────────────────────────────────────────────────────────────────
    //     SEETINGS PANEL
    // ───────────────────────────────────────────────────────────────────────────── */

/* ── Element refs ───────────────────────────────────────────── */
const overlay = document.getElementById("settingsOverlay");
const sidebar = document.getElementById("settingsSidebar");
const contentPane = document.getElementById("settingsContent");
const closeBtn = document.getElementById("settingsClose");
const openBtn = document.getElementById("settingsOpenBtn");

/* ── Open / close ───────────────────────────────────────────── */
function openSettings() {
    overlay.classList.add("active");
    sidebar.classList.add("open");
    // auto-open first pane
    const active = sidebar.querySelector(".set-item.active");
    if (active) loadPage(active.dataset.page, active);
}

function closeSettings() {
    overlay.classList.remove("active");
    sidebar.classList.remove("open");
    contentPane.classList.remove("open");
}

openBtn.addEventListener("click", openSettings);
closeBtn.addEventListener("click", closeSettings);
overlay.addEventListener("click", closeSettings);

/* ── Escape key ─────────────────────────────────────────────── */
document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeSettings();
});
