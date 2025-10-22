import SwiftUI

final class ProjectState: ObservableObject {
    @Published var openFilePaths: [String]
    @Published var selectedFile: String?
    @Published var activeSpecSection: String?
    @Published var projectFolderURL: URL?
    @Published var specSections: [SpecSection]

    var projectFolderPath: String? {
        projectFolderURL?.path
    }

    init(openFilePaths: [String] = [],
         selectedFile: String? = nil,
         activeSpecSection: String? = nil,
         projectFolderURL: URL? = nil,
         specSections: [SpecSection] = []) {
        self.openFilePaths = openFilePaths
        self.selectedFile = selectedFile
        self.activeSpecSection = activeSpecSection
        self.projectFolderURL = projectFolderURL
        self.specSections = specSections
    }

    func loadFiles(from folder: URL) {
        let files = FileLoader.loadProjectFiles(at: folder)
        projectFolderURL = folder
        openFilePaths = files

        let specURL = folder.appendingPathComponent("AgentSpec.json")
        if FileManager.default.fileExists(atPath: specURL.path) {
            loadSpec(from: specURL)
        } else {
            specSections = []
            activeSpecSection = nil
        }

        if let currentSelection = selectedFile, files.contains(currentSelection) {
            return
        }

        selectedFile = files.first
    }

    func loadSpec(from url: URL) {
        let loadedSections = SpecLoader.loadSpec(from: url)
        specSections = loadedSections

        if let currentSection = activeSpecSection,
           loadedSections.contains(where: { $0.title == currentSection }) {
            activeSpecSection = currentSection
        } else {
            activeSpecSection = loadedSections.first?.title
        }
    }
}
