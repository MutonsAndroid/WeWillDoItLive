import SwiftUI

struct WeWillDoItLiveApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var projectState = ProjectState()
    @StateObject private var engine = OpenCodeEngine()

    var body: some Scene {
        WindowGroup {
            MainWindowView()
                .environmentObject(themeManager)
                .environmentObject(projectState)
                .environmentObject(engine)
                .onAppear {
                    if let session = SessionManager.shared.load() {
                        if let url = session.projectFolderURL {
                            let resolvedURL = url.standardizedFileURL
                            if FileManager.default.fileExists(atPath: resolvedURL.path) {
                                projectState.loadFiles(from: resolvedURL)
                            }
                        }
                        projectState.activeSpecSection = session.activeSpecSection
                    }
                }
                .onDisappear {
                    let session = SessionData(
                        selectedFile: projectState.selectedFile,
                        activeSpecSection: projectState.activeSpecSection,
                        projectFolderURL: projectState.projectFolderURL
                    )
                    SessionManager.shared.save(session: session)
                }
        }
    }
}

WeWillDoItLiveApp.main()
