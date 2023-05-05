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

@app.route('/api/projects/update/<int:project_id>', methods=['PUT'])
def update_project(project_id):
    try:
        projectData = request.get_json()
        id = projectData['id']
        name = projectData['name']
        description = projectData['description']
        start_date = projectData['start_date']
        end_date = projectData['end_date']
        user_id = projectData['user_id']
        isComplete = projectData['isComplete']
        
        conn = get_db_connection()
        conn.execute('''UPDATE projects SET name=?, description=?, start_date=?, end_date=?, user_id=?, isComplete=?
                        WHERE id=?''', (name, description, start_date, end_date, user_id, isComplete, id))
        conn.commit()
        
        updated_project = conn.execute('SELECT * FROM projects WHERE id=?', (id,)).fetchone()
        return jsonify(dict(updated_project))
    except:
        return jsonify({"Update_Success": False})
    finally:
        print(f"Finalising /api/projects/update")
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
        
@app.route('/api/projects/get/by_user_id/<int:user_id>')
def fetch_projects_by_user_id(user_id):
    try:
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT * FROM projects WHERE user_id=?', (user_id,)).fetchall())
    except:
        return jsonify({"Error" : "No projects to return for the specified user!"})
    finally:
        print(f"Finalising /api/projects/get/by_user_id/{user_id}")
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

        
@app.route('/api/projects/update/<int:project_id>', methods=['PUT'])


@app.route('/api/projects/delete/<int:project_id>', methods=['DELETE'])
def delete_project(project_id):
    try:
        conn = get_db_connection()
        conn.execute('DELETE FROM projects WHERE id=?', (project_id,))
        conn.commit()
        return jsonify({"Delete_Success": True})
    except:
        return jsonify({"Delete_Success": False})
    finally:
        print(f"Finalising /api/projects/delete")
        conn.close()
        
def update_project(project_id):
    try:
        projectData = request.get_json()
        id = projectData['id']
        name = projectData['name']
        description = projectData['description']
        start_date = projectData['start_date']
        end_date = projectData['end_date']
        user_id = projectData['user_id']
        isComplete = projectData['isComplete']
        conn = get_db_connection()
        conn.execute('''UPDATE projects SET name=?, description=?, start_date=?, end_date=?, user_id=?, isComplete=?
                        WHERE id=?''', (name, description, start_date, end_date, user_id, isComplete, id))
        conn.commit()
        updated_project = conn.execute('SELECT * FROM projects WHERE id=?', (id,)).fetchone()
        return jsonify(dict(updated_project))
    except:
        return jsonify({"Update_Success": False})
    finally:
        print(f"Finalising /api/projects/update")
        conn.close()

@app.route('/api/tasks/get/by_project_id/<int:project_id>')
def fetch_tasks_by_project_id(project_id):
    try:
        conn = get_db_connection()
        return SQL_to_json(conn.execute('SELECT*FROM tasks WHERE project_id=?', (project_id,)).fetchall())
    except:
        return jsonify({"Error" : "No tasks to return to the specified project!"})
    finally:
        print(f"Finalising /api/tasks/get/by_project_id/{project_id}")
        conn.close()

@app.route('/api/tasks/update/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    try:
        taskData = request.get_json()
        id = taskData['id']
        name = taskData['name']
        description = taskData['description']
        due_date = taskData['due_date']
        status = taskData['status']
        project_id = taskData['project_id']
        
        conn = get_db_connection()
        conn.execute('''UPDATE tasks SET name=?, description=?, due_date=?, status=?, project_id=? WHERE id=?''', (name, description, due_date, status, project_id, id))
        conn.commit()
        
        update_task = conn.execute('SELECT*FROM tasks WHERE id=?', (id,)).fetchone()
        return jsonify(dict(update_task))
    except:
        return jsonify({"Update_Success":False})
    finally:
        print(f"Finalising /api/tasks/update")
        conn.close()

@app.route('/api/tasks/delete/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    try:
        conn = get_db_connection()
        conn.execute('DELETE FROM tasks WHERE id=?', (task_id,))
        conn.commit()
        return jsonify({"Delete_Success":True})
    except:
        return jsonify({"Delete_Success":False})
    finally:
        print(f"Finalising /api/tasks/delete")
        conn.close()

if __name__ == '__main__':
    #ifdb.initdb()
    app.run()
