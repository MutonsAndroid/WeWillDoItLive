import Foundation

struct FileLoader {
    static func loadProjectFiles(at path: URL) -> [String] {
        let supportedExtensions: Set<String> = ["swift", "md", "json"]
        let fileManager = FileManager.default

        guard let directoryContents = try? fileManager.contentsOfDirectory(at: path,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles]) else {
            return []
        }

        return directoryContents
            .filter { supportedExtensions.contains($0.pathExtension.lowercased()) }
            .map { $0.lastPathComponent }
            .sorted()
    }
}
