import sqlite3
import hashlib
import random
import datetime

HASH_SALT = "LetsMakeProjects!"

def initdb():
    connection = sqlite3.connect('database.db')

    with open('schema.sql') as f:
        # Create the tables specified in the schema
        connection.executescript(f.read())

        cur = connection.cursor()

        #Insert example users
        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                    ('BenPople', hashlib.sha256(('H4rdw4re' + HASH_SALT).encode()).hexdigest(), 'popleb@btc.ac.uk'))

        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                    ('SimonWest', hashlib.sha256(('H4rdw4re' + HASH_SALT).encode()).hexdigest(), 'wests@btc.ac.uk'))

        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                ('EmilyWang', hashlib.sha256(('p@ssword1' + HASH_SALT).encode()).hexdigest(), 'emilyw@xyz.com'))

        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                    ('MikeSmith', hashlib.sha256(('myPa$$w0rd' + HASH_SALT).encode()).hexdigest(), 'mikes@abc.com'))

        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                    ('AliceJones', hashlib.sha256(('secret12' + HASH_SALT).encode()).hexdigest(), 'alicej@def.com'))

        cur.execute("INSERT INTO users (username, password, email) VALUES (?, ?, ?)",
                    ('BobLee', hashlib.sha256(('qwerty123' + HASH_SALT).encode()).hexdigest(), 'bobl@ghi.com'))

        #Insert example project entries
        #Define a list of user IDs
        user_ids = [1, 2, 3, 4, 5, 6]

        #Generate 20 random project entries
        for i in range(20):
            #Select a random user ID
            user_id = random.choice(user_ids)
            
            #Generate a random start date within the last 30 days
            days_ago = random.randint(0, 30)
            start_date = datetime.date.today() - datetime.timedelta(days=days_ago)
            
            #Generate a random end date between 30 and 90 days from the start date
            end_date = start_date + datetime.timedelta(days=random.randint(30, 90))
            
            #Generate a random project name and description
            project_name = f"Project {i}"
            project_description = f"This is the description for project {i}."
            
            #Insert the new project entry into the projects table
            cur.execute("INSERT INTO projects (name, description, start_date, end_date, user_id) VALUES (?, ?, ?, ?, ?)",
                        (project_name, project_description, start_date, end_date, user_id))
            
            project_id = cur.lastrowid

            #Insert example task entries for each project
            for j in range(random.randint(3, 10)):
                #Generate a random task name and description
                task_name = f"Task {j} for project {i}"
                task_description = f"This is the description for task {j} for project {i}."

                #Generate a random due date within the project's start and end dates
                due_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days))

                #Generate a random task status
                task_status = random.choice(['Not started', 'In progress', 'Complete'])

                #Insert the new task entry into the tasks table
                cur.execute("INSERT INTO tasks (name, description, due_date, status, project_id) VALUES (?, ?, ?, ?, ?)",
                            (task_name, task_description, due_date, task_status, project_id))

    connection.commit()
    connection.close()