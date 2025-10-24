import Foundation

enum SpecDeckRepository {
    private static let agentOSDirectory = URL(fileURLWithPath: "/agentos/specs/")
    private static let fallbackDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    private static let fallbackFileName = "specs.json"

    static func loadTasks() -> [SpecTask] {
        for url in candidateURLs() {
            if let tasks = tryLoad(from: url) {
                return tasks
            }
        }
        return sampleTasks()
    }

    static func candidateURLs() -> [URL] {
        var urls: [URL] = []
        let agentOSFile = agentOSDirectory.appendingPathComponent(fallbackFileName)
        urls.append(agentOSFile)

        let workspaceDataFile = fallbackDirectory.appendingPathComponent("data").appendingPathComponent(fallbackFileName)
        urls.append(workspaceDataFile)

        return urls
    }

    private static func tryLoad(from url: URL) -> [SpecTask]? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let tasks = try JSONDecoder().decode([SpecTask].self, from: data)
            return tasks
        } catch {
            print("SpecDeckRepository failed to decode \(url.lastPathComponent): \(error)")
            return nil
        }
    }

    private static func sampleTasks() -> [SpecTask] {
        [
            SpecTask(
                title: "Implement Floating Input Bar",
                description: "Create an animated floating input bar for the chat composer with context actions.",
                model: "gpt-5-codex",
                progress: 78,
                status: .running,
                validation: "Confirm the bar animates smoothly, persists drafts, and respects theming.",
                assignee: "AVA"
            ),
            SpecTask(
                title: "Add File Tree Capsule Highlight",
                description: "Highlight the selected file node with a glowing capsule accent and smooth hover fade.",
                model: "gpt-5-codex",
                progress: 16,
                status: .pending,
                validation: "Ensure the selection state persists across focus changes and keyboard navigation.",
                assignee: "JO"
            ),
            SpecTask(
                title: "Integrate OpenCode Validation",
                description: "Wire OpenCode validation logs into the execution stream and persist run history.",
                model: "gpt-5-codex",
                progress: 0,
                status: .pending,
                validation: "Validation errors should surface inline with actionable remediation steps.",
                assignee: "KAI"
            )
        ]
    }
}
