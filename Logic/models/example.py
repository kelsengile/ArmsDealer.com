from data.db import get_db


class ExampleModel:
    @staticmethod
    def get_all():
        db = get_db()
        return db.execute('SELECT * FROM example').fetchall()

    @staticmethod
    def create(name):
        db = get_db()
        db.execute('INSERT INTO example (name) VALUES (?)', (name,))
        db.commit()
