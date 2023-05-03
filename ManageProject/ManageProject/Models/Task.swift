struct Task: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let due_date: String
    let status: String
    let project_id: Int

    var statusString: String {
        switch status {
        case "0":
            return "On Going"
        case "1":
            return "Completed"
        default:
            return "Unknown"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, due_date, status, project_id
    }
}
