from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import hashlib
import initflaskdb as ifdb

app = Flask(__name__)
CORS(app)

HASH_SALT = "LetsMakeProjects!"
DATABASE_NAME = "database.db"

def get_db_connection():
    conn = sqlite3.connect(DATABASE_NAME)
    conn.row_factory = sqlite3.Row
    return conn

def SQL_to_json(sql_rows):
    return jsonify([dict(ix) for ix in sql_rows])

@app.route('/api/users/get/all')
def fetch_all_users():
    try:
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM users').fetchall())
    except:
        return jsonify({"Error" : "No users to return!"})
    finally:
        print(f"Finalising /api/users/get/all")
        conn.close()

@app.route('/api/users/get/byid')
def fetch_user_by_id():
    try:
        userId = request.args.get('id')
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM users WHERE id=?', (userId,)).fetchall())
    except:
        return jsonify({"Error" : "User does not exist!"})
    finally:
        print(f"Finalising /api/users/get/byid")
        conn.close()

@app.route('/api/users/login', methods=['POST'])
def login_user():
    try:
        loginData = request.get_json()
        username = loginData['username']
        password = hashlib.md5((loginData['password'] + HASH_SALT).encode()).hexdigest()

        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM users WHERE username = ? AND password = ?', (username, password)).fetchall())
    except:
        return jsonify({"Login" : False})
    finally:
        print(f"Finalising /api/users/login")
        conn.close()

@app.route('/api/users/register', methods=['POST'])
def add_new_user():
    try:
        userData = request.get_json()
        username = userData['username']
        password = hashlib.md5((userData['password'] + HASH_SALT).encode()).hexdigest()
        email = userData['email']

        conn = get_db_connection()
        conn.execute('INSERT INTO users (username, password, email) VALUES (?, ?, ?)', (username, password, email))

        return jsonify({"Register_Success" : True})
    except:
        return jsonify({"Register_Success" : False})
    finally:
        print(f"Finalising /api/users/register")
        conn.commit()
        conn.close()

@app.route('/api/projects/get/all')
def fetch_all_projects():
    try:
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM projects').fetchall())
    except:
        return jsonify({"Error" : "No projects to return!"})
    finally:
        print(f"Finalising /api/projects/get/all")
        conn.close()

@app.route('/api/projects/get/byid')
def fetch_project_by_id():
    try:
        projectId = request.args.get('id')
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM projects WHERE id=?', (projectId,)).fetchall())
    except:
        return jsonify({"Error" : "Project does not exist!"})
    finally:
        print(f"Finalising /api/projects/get/byid")
        conn.close()

@app.route('/api/projects/add', methods=['POST'])
def add_new_project():
    try:
        projectData = request.get_json()
        name = projectData['name']
        description = projectData['description']
        start_date = projectData['start_date']
        end_date = projectData['end_date']
        user_id = projectData['user_id']
        conn = get_db_connection()
        conn.execute('INSERT INTO projects (name, description, start_date, end_date, user_id) VALUES (?, ?, ?, ?, ?)', (name, description, start_date, end_date, user_id))

        return jsonify({"Add_Success" : True})
    except:
        return jsonify({"Add_Success" : False})
    finally:
        print(f"Finalising /api/projects/add")
        conn.commit()
        conn.close()

@app.route('/api/tasks/get/all')
def fetch_all_tasks():
    try:
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM tasks').fetchall())
    except:
        return jsonify({"Error" : "No tasks to return!"})
    finally:
        print(f"Finalising /api/tasks/get/all")
        conn.close()

@app.route('/api/tasks/get/byid')
def fetch_task_by_id():
    try:
        taskId = request.args.get('id')
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM tasks WHERE id=?', (taskId,)).fetchall())
    except:
        return jsonify({"Error" : "Task does not exist!"})
    finally:
        print(f"Finalising /api/tasks/get/byid")
        conn.close()

@app.route('/api/tasks/add', methods=['POST'])
def add_new_task():
    try:
        taskData = request.get_json()
        name = taskData['name']
        description = taskData['description']
        due_date = taskData['due_date']
        status = taskData['status']
        project_id = taskData['project_id']
        conn = get_db_connection()
        conn.execute('INSERT INTO tasks (name, description, due_date, status, project_id) VALUES (?, ?, ?, ?, ?)', (name, description, due_date, status, project_id))

        return jsonify({"Add_Success" : True})
    except:
        return jsonify({"Add_Success" : False})
    finally:
        print(f"Finalising /api/tasks/add")
        conn.commit()
        conn.close()

if __name__ == '__main__':
    ifdb.initdb()
    app.run()