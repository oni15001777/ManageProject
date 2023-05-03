import UIKit


class ProjectViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ProjectDetailViewControllerDelegate {
    
    func projectDetailViewController(_ controller: ProjectDetailViewController, didUpdateProject updatedProject: Project) {
        if let index = projects.firstIndex(where: { $0.id == updatedProject.id }) {
            projects[index] = updatedProject
            projectPickerView.reloadAllComponents()
        }
    }
        
    func projectDetailViewControllerDidCreateTask(_ controller: UIViewController) {

    }
    
    @IBOutlet weak var projectPickerView: UIPickerView!
    @IBOutlet weak var openProjectButtonPressed: UIButton!
    
    var projects: [Project] = [] {
        didSet {
            DispatchQueue.main.async {
                self.projectPickerView.dataSource = self
                self.projectPickerView.delegate = self
                self.projectPickerView.reloadAllComponents()
            }
        }
    }
    
    var selectedProject: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = UserData.shared.currentUser else { return }
        
        let name = currentUser.username
        self.title = "\(name)'s Projects"
        
        projectPickerView.dataSource = self
        projectPickerView.delegate = self
        
        openProjectButtonPressed.addTarget(self, action: #selector(openProjectButtonTapped(_:)), for: .touchUpInside)
        
        if let userId = UserData.shared.currentUser?.id {
            fetchProjectDetails(forUserId: userId)
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        print("numberOfComponents called")
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("numberOfRowsInComponent called, count: \(projects.count)")
        return projects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("Row: \(row)")
        if row < projects.count {
            print("Project name: \(projects[row].name)")
            return projects[row].name
        } else {
            return ""
        }
    }
    
    
    @objc func openProjectButtonTapped(_ sender: UIButton) {
        let selectedIndex = projectPickerView.selectedRow(inComponent: 0)
        selectedProject = projects[selectedIndex]
        print("View/Edit button tapped for project: \(selectedProject?.name ?? "")")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let projectDetailVC = storyboard.instantiateViewController(withIdentifier: "ProjectDetailVC") as? ProjectDetailViewController {
            projectDetailVC.project = selectedProject
            projectDetailVC.delegate = self
            navigationController?.pushViewController(projectDetailVC, animated: true)
        }
    }
    
    func fetchProjectDetails(forUserId userId: Int) {
        let apiUrl = "http://127.0.0.1:5000/api/projects/get/by_user_id/\(userId)"
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
            
            // Print JSON data received from the API call
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON data: \(jsonString)")
            }
            
            do {
                self.projects = try JSONDecoder().decode([Project].self, from: data)
                print("Parsed projects for user \(userId): \(self.projects)")
                DispatchQueue.main.async {
                    self.projectPickerView.reloadAllComponents()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
    
}
