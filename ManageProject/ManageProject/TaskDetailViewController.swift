import UIKit

// Protocol that defines the methods that the delegate object of this view controller must implement
protocol TaskDetailViewControllerDelegate: AnyObject {
    func didUpdateTask(_ viewController: TaskDetailViewController)
    func didDeleteTask(_ viewController: TaskDetailViewController)
}


class TaskDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var taskDesc: UITextField!
    @IBOutlet weak var dueDate: UIDatePicker!
    @IBOutlet weak var status: UIPickerView!
    @IBOutlet weak var errorTask: UILabel!
    
    // Weak reference to the delegate object
    weak var delegate: TaskDetailViewControllerDelegate?
    
    // Task object that this view controller is currently displaying
    var task: Task?
    
    // Array of status options to display in the status picker
    let statusOptions = ["On Going", "Completed"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate and data source of the status picker to this view controller
        status.delegate = self
        status.dataSource = self
        
        // If a task object is set, update the text fields and date picker with its information
        if let task = task {
            taskName.text = task.name
            taskDesc.text = task.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: task.due_date) {
                dueDate.date = date
            }
            
            if let statusIndex = statusOptions.firstIndex(of: task.statusString) {
                status.selectRow(statusIndex, inComponent: 0, animated: false)
            }
            
        }
    }
    
    // Returns the selected status from the status picker
    func getStatusFromSelectedRow() -> String {
        let selectedIndex = status.selectedRow(inComponent: 0)
        return statusOptions[selectedIndex]
    }
    
    // Returns the selected status from the status picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Returns the selected status from the status picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusOptions.count
    }
    
    // Title for a row in the status picker (based on the status options)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusOptions[row]
    }
    
    // Called when the update button is pressed
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        updateTask()
    }
    
    // Called when the delete button is pressed
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        deleteTask()
    }
    
    // Constructs a URL request to update the task, sends the request, and handles the response
    func updateTask() {
        guard let task = task else { return }
        
        let url = URL(string: "http://127.0.0.1:5000/api/tasks/update/\(task.id)")
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dueDateString = dateFormatter.string(from: dueDate.date)
        
        let updatedTaskStatus: String = getStatusFromSelectedRow()
        let updatedTask = Task(id: task.id, name: taskName.text!, description: taskDesc.text!, due_date: dueDateString, status: updatedTaskStatus, project_id: task.project_id)
        
        do {
            let data = try JSONEncoder().encode(updatedTask)
            request.httpBody = data
        } catch {
            print("Error encoding task: \(error)")
        }
        
        let updateTaskRequest = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                let updateResult = try JSONDecoder().decode([String: Bool].self, from: data)
                if let success = updateResult["Update_Success"], success {
                    print("Task updated successfully")
                }
                else {
                    print("Error updating task")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        updateTaskRequest.resume()
        //Calls the delegate function to send back to the previous screen
        DispatchQueue.main.async {
            self.delegate?.didUpdateTask(self)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Constructs a URL request to update the task, sends the request, and handles the response
    func deleteTask() {
        guard let task = task else { return }
        
        let url = URL(string: "http://127.0.0.1:5000/api/tasks/delete/\(task.id)")
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        
        let deleteTaskRequest = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                let deleteResult = try JSONDecoder().decode([String: Bool].self, from: data)
                if let success = deleteResult["Delete_Success"], success {
                    print("Task deleted successfully")
                    DispatchQueue.main.async {
                        self.delegate?.didDeleteTask(self)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    print("Error deleting task")
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        deleteTaskRequest.resume()
    }
    
}
