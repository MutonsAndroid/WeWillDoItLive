import Foundation

struct SessionData: Codable {
    var selectedFile: String?
    var activeSpecSection: String?
    var projectFolderURL: URL?

    var projectFolderPath: String? {
        projectFolderURL?.path
    }

    init(selectedFile: String? = nil,
         activeSpecSection: String? = nil,
         projectFolderURL: URL? = nil) {
        self.selectedFile = selectedFile
        self.activeSpecSection = activeSpecSection
        self.projectFolderURL = projectFolderURL
    }

    private enum CodingKeys: String, CodingKey {
        case selectedFile
        case activeSpecSection
        case projectFolderURL
        case projectFolderPath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedFile = try container.decodeIfPresent(String.self, forKey: .selectedFile)
        activeSpecSection = try container.decodeIfPresent(String.self, forKey: .activeSpecSection)

        if let storedURL = try container.decodeIfPresent(URL.self, forKey: .projectFolderURL) {
            projectFolderURL = storedURL
        } else if let path = try container.decodeIfPresent(String.self, forKey: .projectFolderPath) {
            projectFolderURL = URL(fileURLWithPath: path)
        } else {
            projectFolderURL = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedFile, forKey: .selectedFile)
        try container.encodeIfPresent(activeSpecSection, forKey: .activeSpecSection)
        try container.encodeIfPresent(projectFolderURL, forKey: .projectFolderURL)
    }
}

final class SessionManager {
    static let shared = SessionManager()
    private let sessionKey = "WeWillDoItLive.LastSession"

    private init() {}

    func save(session: SessionData) {
        if let data = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
    }

    func load() -> SessionData? {
        guard let data = UserDefaults.standard.data(forKey: sessionKey) else { return nil }
        return try? JSONDecoder().decode(SessionData.self, from: data)
    }
}
