
import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let username: String
    let password: String
}
