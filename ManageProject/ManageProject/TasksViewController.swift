import UIKit

extension TasksViewController: TaskDetailViewControllerDelegate {
    func didUpdateTask(_ viewController: TaskDetailViewController) {
        shouldReloadDataOnAppear = true
    }
    
    func didDeleteTask(_ viewController: TaskDetailViewController) {
        shouldReloadDataOnAppear = true
    }
}


class TasksViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var taskPickerView: UIPickerView!
    
    var projectID: Int?
        var tasks: [Task] = []
        var shouldReloadDataOnAppear = true
        
        override func viewDidLoad() {
            super.viewDidLoad()
            taskPickerView.delegate = self
            taskPickerView.dataSource = self
            fetchProjectTasks()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if shouldReloadDataOnAppear {
                fetchProjectTasks()
                shouldReloadDataOnAppear = false
            }
            print("Tasks in viewWillAppear: \(tasks)")
            print("Tasks count in viewWillAppear: \(tasks.count)")
        }
    
    func fetchProjectTasks() {
        guard let projectId = projectID else { return }
        let apiUrl = "http://127.0.0.1:5000/api/tasks/get/by_project_id/\(projectId)"
        print("API URL: \(apiUrl)")
        guard let url = URL(string: apiUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                self.tasks = try JSONDecoder().decode([Task].self, from: data)
                print("Parsed tasks for project \(projectId): \(self.tasks)")
                print("Fetched tasks: \(self.tasks)")
                print("Tasks count: \(self.tasks.count)")

                DispatchQueue.main.async {
                    self.taskPickerView.reloadAllComponents()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tasks.count > 0 ? tasks.count : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if tasks.count > 0 {
            return tasks[row].name
        } else {
            return "No tasks available"
        }
    }
    
    @IBAction func openTaskButtonPressed(_ sender: UIButton) {
        let selectedTaskIndex = taskPickerView.selectedRow(inComponent: 0)
        let selectedTask = tasks[selectedTaskIndex]
        navigateToTaskDetailsViewController(task: selectedTask)
    }
    
    func navigateToTaskDetailsViewController(task: Task) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let taskDetailVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailViewController") as? TaskDetailViewController {
            taskDetailVC.task = task
            taskDetailVC.delegate = self
            self.navigationController?.pushViewController(taskDetailVC, animated: true)
        } else {
            print("Error: Failed to instantiate TaskDetailViewController from storyboard")
        }
    }
}
