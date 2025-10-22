import SwiftUI
import AppKit

struct ProjectPickerView: View {
    @EnvironmentObject private var project: ProjectState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Select a Project Folder")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a directory to load Swift, Markdown, and JSON files into the workspace.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { openFolderPicker() }) {
                Label("Open Project Folder", systemImage: "folder.open")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.accentColor.opacity(0.2))
                    .foregroundColor(.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            if !recentProjects.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Projects")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    ForEach(recentProjects, id: \.self) { path in
                        Button(action: { openRecentProject(path: path) }) {
                            Label(path, systemImage: "clock")
                                .font(.footnote)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(24)
        .frame(minWidth: 360)
    }

    private var recentProjects: [String] {
        RecentProjectsManager.getRecentProjects()
    }

    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.prompt = "Open"

        if panel.runModal() == .OK, let url = panel.url {
            handleSelection(url: url)
        }
    }

    private func openRecentProject(path: String) {
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        handleSelection(url: url)
    }

    private func handleSelection(url: URL) {
        project.loadFiles(from: url)
        RecentProjectsManager.save(projectURL: url)
        dismiss()
    }
}

/*
#Preview {
    ProjectPickerView()
        .environmentObject(ProjectState())
}
*/
