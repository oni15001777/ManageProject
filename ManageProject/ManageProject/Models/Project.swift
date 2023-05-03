import Foundation

struct Project: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let start_date: String
    let end_date: String
    let user_id: Int
    let isComplete: Int

    var isCompleted: Bool {
        return isComplete == 1
    }

    init(id: Int, name: String, description: String, start_date: String, end_date: String, user_id: Int, isComplete: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.start_date = start_date
        self.end_date = end_date
        self.user_id = user_id
        self.isComplete = isComplete
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, start_date, end_date, user_id, isComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        start_date = try container.decode(String.self, forKey: .start_date)
        end_date = try container.decode(String.self, forKey: .end_date)
        user_id = try container.decode(Int.self, forKey: .user_id)
        isComplete = try container.decodeIfPresent(Int.self, forKey: .isComplete) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(start_date, forKey: .start_date)
        try container.encode(end_date, forKey: .end_date)
        try container.encode(user_id, forKey: .user_id)
        try container.encode(isComplete, forKey: .isComplete)
    }
}
