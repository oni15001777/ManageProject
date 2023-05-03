
import UIKit

class Main_LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var notification: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButton(_sender: UIButton) {
        var loggedIn = false
        guard let username = username.text,
              let password = password.text else {
            return
        }
        let parameters = ["username": username, "password": password]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/users/login") else {
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
                let userData = try JSONDecoder().decode([User].self, from: data)
                if userData.count > 0 {
                    
                    UserData.shared.currentUser = userData[0]
                    DispatchQueue.main.async {
                        loggedIn = true
                        self.notification.text = "Logged in \(userData[0].username)"
                    }
                    print("User logged in successfully")
                } else {
                    print("Invalid username or password")
                    DispatchQueue.main.async {
                        self.notification.text = "Invalid username or password."
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            if (loggedIn == true) {
                DispatchQueue.main.async {
                    let uservc = (self.storyboard?.instantiateViewController(withIdentifier: "UserVC"))!
                    self.navigationController?.pushViewController(uservc, animated: true)
                }
            }
        }.resume()
    }
}
