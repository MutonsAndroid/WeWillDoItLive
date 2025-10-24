import Foundation

struct FileNode: Identifiable {
    let id = UUID()
    let url: URL
    var children: [FileNode] = []
    var isExpanded = false

    var isDirectory: Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }

    var name: String {
        url.lastPathComponent
    }

    static func buildTree(from url: URL) -> FileNode {
        var node = FileNode(url: url)

        guard node.isDirectory,
              let items = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
        else {
            return node
        }

        node.children = items
            .map { buildTree(from: $0) }
            .sorted { lhs, rhs in
                switch (lhs.isDirectory, rhs.isDirectory) {
                case (true, false):
                    return true
                case (false, true):
                    return false
                default:
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
            }

        return node
    }

    func filtered(using query: String) -> FileNode? {
        guard !query.isEmpty else {
            return self
        }

        let lowercasedQuery = query.lowercased()

        if name.lowercased().contains(lowercasedQuery) {
            return self
        }

        let filteredChildren = children.compactMap { $0.filtered(using: query) }

        guard !filteredChildren.isEmpty else {
            return nil
        }

        var copy = self
        copy.children = filteredChildren
        copy.isExpanded = true
        return copy
    }
}
