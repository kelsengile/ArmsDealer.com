# ──────────────────────────────────────────────────────────────────────────────────
# CART & CHECKOUT ROUTES
# ──────────────────────────────────────────────────────────────────────────────────
from flask import Blueprint, render_template

cart_bp = Blueprint('cart', __name__)


@cart_bp.route('/cart')
def cart():
    return render_template('user/cart.html')


@cart_bp.route('/checkout')
def checkout():
    return render_template('user/checkout.html')
