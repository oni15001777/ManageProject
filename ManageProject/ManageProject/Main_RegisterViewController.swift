
import UIKit

class Main_RegisterViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var registerNotification: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func registerButton(_sender: UIButton){
        guard let username = username.text,
              let password = password.text,
              let email = email.text else {
            return
        }
        
        let parameters = ["username": username, "password": password, "email": email]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/users/register") else {
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = json as? [String: Any],
                   let registerSuccess = dict["Register_Success"] as? Bool,
                   registerSuccess == true {
                    
                    DispatchQueue.main.async {
                        self.registerNotification.text = "Registration succesfuly!"
                        let loginvc = (self.storyboard?.instantiateViewController(withIdentifier: "LoginVC"))!
                        self.navigationController?.pushViewController(loginvc, animated: true)
                    }
                    print("User registration successful")
                } else {
                    print("User registration failed")
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
