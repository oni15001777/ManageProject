
import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = UserData.shared.currentUser?.username
        self.title = "Welcome, \(name!)"

    }
}
