import Foundation

struct CodexTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var codeSnippet: String

    init(id: UUID = UUID(), title: String, description: String, codeSnippet: String) {
        self.id = id
        self.title = title
        self.description = description
        self.codeSnippet = codeSnippet
    }

    init(specTask: SpecTask) {
        self.id = specTask.id
        self.title = specTask.title
        self.description = specTask.description
        self.codeSnippet = CodexTask.makeSnippet(from: specTask)
    }

    private static func makeSnippet(from task: SpecTask) -> String {
        let title = task.title.escapedForSwiftLiteral()
        let summary = task.description.escapedForSwiftLiteral()
        let validation = task.validation.escapedForSwiftLiteral()

        return """
        print("Running Codex Task: \(title)")
        print("Summary: \(summary)")
        print("Validation Focus: \(validation)")
        """
    }
}

private extension String {
    func escapedForSwiftLiteral() -> String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}
