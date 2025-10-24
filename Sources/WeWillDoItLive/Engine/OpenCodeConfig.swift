import Foundation

struct OpenCodeConfig: Codable, Identifiable {
    var id: UUID
    var defaultInterpreter: Interpreter
    var envVars: [String: String]
    var pythonPath: String
    var shellPath: String

    enum Interpreter: String, Codable, CaseIterable {
        case swift = "Swift"
        case python = "Python"
        case shell = "Shell"
    }

    enum CodingKeys: String, CodingKey {
        case id, defaultInterpreter, envVars, pythonPath, shellPath
    }

    init(
        id: UUID = UUID(),
        defaultInterpreter: Interpreter = .swift,
        envVars: [String: String] = [:],
        pythonPath: String = "/usr/bin/python3",
        shellPath: String = "/bin/zsh"
    ) {
        self.id = id
        self.defaultInterpreter = defaultInterpreter
        self.envVars = envVars
        self.pythonPath = pythonPath
        self.shellPath = shellPath
    }

    static let configURL: URL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/OpenCodeConfig.json")

    static func load() -> OpenCodeConfig {
        guard let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(OpenCodeConfig.self, from: data)
        else { return OpenCodeConfig() }
        return config
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: Self.configURL, options: .atomic)
        }
    }
}

extension OpenCodeConfig {
    static let historyURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/OpenCodeHistory.json")

    static let lastSessionURL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/OpenCodeLastSession.txt")
}
