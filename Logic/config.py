import os

BASE_DIR = os.path.abspath(os.path.dirname(__file__))


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'your-secret-key-here'
    DATABASE = os.path.join(BASE_DIR, '../data/armsdealer.db')
    DEBUG = True
