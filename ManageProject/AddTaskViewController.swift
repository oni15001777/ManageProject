import UIKit

class AddTaskViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDescTextField: UITextField!
    @IBOutlet weak var taskDueDateDatePicker: UIDatePicker!
    @IBOutlet weak var statusPickerView: UIPickerView!
    @IBOutlet weak var errorTaskLabel: UILabel!
    
    weak var projectDetailViewControllerDelegate: ProjectDetailViewControllerDelegate?

    
    var projectID: Int?
    var statusOptions = ["On going", "Completed"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusOptions[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusPickerView.delegate = self
        statusPickerView.dataSource = self
        self.title = "Add a task"
    }
    
    @IBAction func addTaskButtonPressed(_ sender: UIButton){
        print("Add Task button pressed")
            
            guard let taskName = taskNameTextField.text,
                  let taskDesc = taskDescTextField.text,
                  let projectId = projectID
            else {
                print("Required information is missing")
                return
            }
        
        let taskDueDate = taskDueDateDatePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let taskDueDateString = dateFormatter.string(from: taskDueDate)
        let taskStatus = statusOptions[statusPickerView.selectedRow(inComponent: 0)]
        
        let parameters: [String: Any] = [
            "name": taskName,
            "description": taskDesc,
            "due_date": taskDueDateString,
            "status": taskStatus,
            "project_id": projectId
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/tasks/add") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
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
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let addSuccess = json?["Add_Success"] as? Bool ?? false
                
                DispatchQueue.main.async {
                    if addSuccess {
                        self.errorTaskLabel.text = "Success!"
                        self.projectDetailViewControllerDelegate?.projectDetailViewControllerDidCreateTask(self)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.errorTaskLabel.text = "Error!"
                    }  
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
