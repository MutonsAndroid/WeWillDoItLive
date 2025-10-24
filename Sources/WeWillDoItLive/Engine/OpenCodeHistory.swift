import Foundation

struct OpenCodeHistoryItem: Codable, Identifiable {
    let id: UUID
    let command: String
    let timestamp: Date
    let interpreter: String
    let outputPreview: String

    init(command: String, interpreter: String, output: String) {
        self.id = UUID()
        self.command = command
        self.timestamp = Date()
        self.interpreter = interpreter
        self.outputPreview = String(output.prefix(300))
    }
}

final class OpenCodeHistory: ObservableObject {
    @Published var items: [OpenCodeHistoryItem] = []

    init() {
        load()
    }

    func add(_ item: OpenCodeHistoryItem) {
        items.insert(item, at: 0)
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: OpenCodeConfig.historyURL, options: .atomic)
    }

    func load() {
        guard let data = try? Data(contentsOf: OpenCodeConfig.historyURL),
              let decoded = try? JSONDecoder().decode([OpenCodeHistoryItem].self, from: data) else { return }
        items = decoded
    }
}
