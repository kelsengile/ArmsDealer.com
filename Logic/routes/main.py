from flask import Blueprint, render_template, jsonify

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    return render_template('index.html')

@bp.route('/api/hello')
def hello():
    return jsonify({'message': 'Hello from Flask!'})
