/**
 * accountpanel.js — ArmsDealer
 * Handles open / close of the account side panel.
 * The nav-btn-account button (desktop + mobile drawer) triggers the panel.
 */

(function () {
    'use strict';

    const overlay = document.getElementById('accountOverlay');
    const sidebar = document.getElementById('accountSidebar');
    const closeBtn = document.getElementById('accountClose');

    // All account buttons — desktop navbar + mobile drawer
    const accountBtns = document.querySelectorAll('.nav-btn-account');

    if (!overlay || !sidebar) return; // guard: panel not in DOM

    /* ── Open / close ─────────────────────────────────────────────── */
    function openAccount() {
        overlay.classList.add('active');
        sidebar.classList.add('open');
        sidebar.setAttribute('aria-hidden', 'false');
    }

    function closeAccount() {
        overlay.classList.remove('active');
        sidebar.classList.remove('open');
        sidebar.setAttribute('aria-hidden', 'true');
    }

    /* ── Bind triggers ────────────────────────────────────────────── */
    accountBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (sidebar.classList.contains('open')) {
                closeAccount();
            } else {
                openAccount();
            }
        });
    });

    if (closeBtn) closeBtn.addEventListener('click', closeAccount);
    overlay.addEventListener('click', closeAccount);

    /* ── Escape key ───────────────────────────────────────────────── */
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeAccount();
    });

    /* ── Forgot Password Toggle ───────────────────────────────────── */
    const forgotBtn = document.getElementById('forgotPasswordBtn');

    if (forgotBtn) {
        forgotBtn.addEventListener('click', () => {
            const target = forgotBtn.dataset.target || '/forgot-password';
            window.location.href = target;
        });
    }
})();