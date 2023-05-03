import UIKit

protocol ProjectDetailViewControllerDelegate: AnyObject {
    func projectDetailViewController(_ controller: ProjectDetailViewController, didUpdateProject updatedProject: Project)
    func projectDetailViewControllerDidCreateTask(_ controller: UIViewController)
}

extension ProjectDetailViewController: ProjectDetailViewControllerDelegate {
    func projectDetailViewController(_ controller: ProjectDetailViewController, didUpdateProject updatedProject: Project) {
    }
    
    func projectDetailViewControllerDidCreateTask(_ controller: UIViewController) {
    }
}


class ProjectDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var isCompletedSwitch: UISwitch!
    @IBOutlet weak var seeTasksButton: UIButton!
    
    var project: Project?
    weak var delegate: ProjectDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayProjectDetails()
        
        let projectName = project?.name
        self.title = "\(projectName!)"
    }
    
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        navigateToAddTaskViewController()
    }

    @IBAction func seeTasksButtonTapped(_ sender: UIButton) {
        navigateToTasksViewController()
    }
    
    func navigateToAddTaskViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addTaskVC = storyboard.instantiateViewController(withIdentifier: "AddTaskViewController") as! AddTaskViewController
            addTaskVC.projectID = self.project?.id // set the projectID property
            addTaskVC.projectDetailViewControllerDelegate = self // set the delegate property
            self.navigationController?.pushViewController(addTaskVC, animated: true)
        }

    func navigateToTasksViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tasksVC = storyboard.instantiateViewController(withIdentifier: "TasksViewController") as! TasksViewController
        tasksVC.projectID = self.project?.id
        self.navigationController?.pushViewController(tasksVC, animated: true)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        updateProject()
    }
    
    func displayProjectDetails() {
        guard let project = project else { return }
        
        nameTextField.text = project.name
        descriptionTextField.text = project.description
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let startDate = dateFormatter.date(from: project.start_date) {
            startDatePicker.date = startDate
        }
        
        if let endDate = dateFormatter.date(from: project.end_date) {
            endDatePicker.date = endDate
        }
        
        isCompletedSwitch.isOn = project.isComplete == 1
    }
    
    func updateProject() {
        guard let project = project else { return }
        let apiUrl = "http://127.0.0.1:5000/api/projects/update/\(project.id)"
        guard let url = URL(string: apiUrl) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.string(from: startDatePicker.date)
        let endDate = dateFormatter.string(from: endDatePicker.date)
        
        let updatedProject = Project(id: project.id,
                                     name: nameTextField.text ?? "",
                                     description: descriptionTextField.text ?? "",
                                     start_date: startDate,
                                     end_date: endDate,
                                     user_id: project.user_id,
                                     isComplete: isCompletedSwitch.isOn ? 1 : 0)
        
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(updatedProject) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                let updatedProject = try JSONDecoder().decode(Project.self, from: data)
                print("Updated project: \(updatedProject)")
                
                DispatchQueue.main.async {
                    self.project = updatedProject
                    self.displayProjectDetails()
                    self.delegate?.projectDetailViewController(self, didUpdateProject: updatedProject)
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        guard let project = project else { return }
        let apiUrl = "http://127.0.0.1:5000/api/projects/delete/\(project.id)"
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let deleteSuccess = responseJson?["Delete_Success"] as? Bool ?? false
                
                print("Delete success: \(deleteSuccess)")
                
                DispatchQueue.main.async {
                    if deleteSuccess {
                        self.delegate?.projectDetailViewController(self, didUpdateProject: project)
                        if let userVC = self.navigationController?.viewControllers.first(where: { $0 is MenuViewController }) {
                            self.navigationController?.popToViewController(userVC, animated: true)
                        } else {
                            print("Error: Failed to find UserVC in navigation stack")
                        }
                    } else {
                        print("Error: Failed to delete project")
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
