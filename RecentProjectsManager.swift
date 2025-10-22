import Foundation

final class RecentProjectsManager {
    private static let key = "WeWillDoItLive.RecentProjects"

    static func save(projectURL: URL) {
        var recents = getRecentProjects()
        recents.removeAll { $0 == projectURL.path }
        recents.insert(projectURL.path, at: 0)
        recents = Array(recents.prefix(5))
        UserDefaults.standard.set(recents, forKey: key)
    }

    static func getRecentProjects() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}
