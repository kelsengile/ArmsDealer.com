from logic.routes import main
from flask import Flask
from flask_cors import CORS
from data.db import init_db

app = Flask(__name__, template_folder='../design/templates',
            static_folder='../design/assets')
CORS(app)

app.register_blueprint(main.bp)

if __name__ == '__main__':
    init_db()
    app.run(debug=True)
