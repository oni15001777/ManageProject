
import Foundation
import UIKit

class AddNewProjectViewController: UIViewController {
    
    @IBOutlet weak var projectNameField: UITextField!
    @IBOutlet weak var projectDescField: UITextField!
    @IBOutlet var startProjectDate: UIDatePicker!
    @IBOutlet var endProjectDate: UIDatePicker!
    @IBOutlet weak var errorProjectLabel: UILabel!
    
    var projectID: Int = 0 // starting with id 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addProjectButtonPressed(_ sender: UIButton) {
        guard let projectName = projectNameField.text,
              let projectDesc = projectDescField.text,
              let userId = UserData.shared.currentUser?.id
        else {
            return
        }
        
        let startDate = startProjectDate.date
        let endDate = endProjectDate.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        let parameters: [String: Any] = [
            "name": projectName,
            "description": projectDesc,
            "start_date": startDateString,
            "end_date": endDateString,
            "user_id": userId,
            "project_id": projectID,
            "isComplete": 0 // Set isComplete to false when creating a new project
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/projects/add") else {
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
                        self.errorProjectLabel.text = "Success!"
                        // Handle successful project addition, e.g., navigate to another view
                        DispatchQueue.main.async {
                            if let navigationController = self.navigationController,
                               let UserVC = navigationController.viewControllers.first(where: { $0.restorationIdentifier == "UserVC" }) {
                                navigationController.popToViewController(UserVC, animated: true)
                            }
                        }
                    } else {
                        self.errorProjectLabel.text = "Error!"
                    }
                    
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
