import Foundation

struct SpecTask: Identifiable, Codable, Equatable {
    enum Status: String, Codable {
        case pending
        case running
        case complete
    }

    let id: UUID
    var title: String
    var description: String
    var model: String
    var progress: Double
    var status: Status
    var validation: String
    var assignee: String?
    var stableKey: String { title.lowercased() }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case model
        case progress
        case status
        case validation
        case assignee
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        model: String,
        progress: Double,
        status: Status,
        validation: String,
        assignee: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.model = model
        self.progress = progress
        self.status = status
        self.validation = validation
        self.assignee = assignee
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.model = try container.decode(String.self, forKey: .model)
        self.progress = try container.decode(Double.self, forKey: .progress)
        self.status = try container.decode(Status.self, forKey: .status)
        self.validation = try container.decode(String.self, forKey: .validation)
        self.assignee = try container.decodeIfPresent(String.self, forKey: .assignee)
    }
}
