import Foundation

struct SpecSection: Identifiable, Decodable {
    let id: UUID
    let title: String
    let content: String

    private enum CodingKeys: String, CodingKey {
        case title
        case content
    }

    init(id: UUID = UUID(), title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
    }
}

enum SpecLoader {
    static func loadSpec(from url: URL) -> [SpecSection] {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([SpecSection].self, from: data)
            return decoded
        } catch {
            print("Failed to load spec: \(error)")
            return []
        }
    }
}
