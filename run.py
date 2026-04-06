from logic.app import app
from data.db import init_db

if __name__ == '__main__':
    init_db()
    app.run(debug=True)
