# This project provides a simple Flask API for managing users, projects, and tasks.

## Getting Started

### Prerequisites
To run this project, you will need to have Python 3 installed, along with the following packages:

- Flask
- Flask-CORS
- SQLite3
- hashlib

### Usage
The API provides the following endpoints:

#### Users
- GET /api/users/get/all - Returns a JSON list of all users in the database
- GET /api/users/get/byid?id={id} - Returns a JSON list of a single user with the specified ID
- POST /api/users/login - Takes a JSON object with username and password fields, and returns a JSON list of the user that matches the provided credentials
- POST /api/users/register - Takes a JSON object with username, password, and email fields, and adds a new user to the database

#### Projects
- GET /api/projects/get/all - Returns a JSON list of all projects in the database
- GET /api/projects/get/byid?id={id} - Returns a JSON list of a single project with the specified ID
- POST /api/projects/add - Takes a JSON object with name, description, start_date, end_date, and user_id fields, and adds a new project to the database

#### Tasks
- GET /api/tasks/get/all - Returns a JSON list of all tasks in the database
- GET /api/tasks/get/byid?id={id} - Returns a JSON list of a single task with the specified ID
- GET /api/tasks/get/byprojectid?project_id={project_id} - Returns a JSON list of all tasks associated with the specified project ID
- POST /api/tasks/add - Takes a JSON object with name, description, due_date, status, and project_id fields, and adds a new task to the database

## License
This project is licensed under the MIT License - see the LICENSE file for details.
