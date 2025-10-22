import SwiftUI

struct CodeEditorView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var project: ProjectState

    @State private var fileContents: String = ""
    @State private var loadError: String?
    @State private var hasUnsavedChanges: Bool = false
    @State private var originalFileContents: String = ""
    @State private var displayMode: EditorDisplayMode = .edit

    private var backgroundColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 36 / 255, green: 43 / 255, blue: 66 / 255)
            : Color(red: 230 / 255, green: 236 / 255, blue: 255 / 255)
    }

    private var textColor: Color {
        theme.currentColorScheme == .dark
            ? Color.white.opacity(0.9)
            : Color(red: 42 / 255, green: 48 / 255, blue: 65 / 255)
    }

    private var isMarkdown: Bool {
        project.selectedFile?.lowercased().hasSuffix(".md") ?? false
    }

    private var markdownAttributedString: AttributedString {
        (try? AttributedString(markdown: fileContents)) ?? AttributedString(fileContents)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Code Editor")
                .font(.system(size: theme.typography.fontSize + 2,
                              weight: .medium,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(textColor)

            Text(headerSubtitle)
                .font(.system(size: theme.typography.fontSize,
                              weight: .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(textColor.opacity(0.8))

            Divider()
                .overlay(textColor.opacity(0.2))

            modePicker

            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            saveButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
        .onAppear(perform: loadSelectedFile)
        .onChange(of: project.selectedFile) { _ in
            displayMode = .edit
            loadSelectedFile()
        }
        .onChange(of: project.projectFolderURL) { _ in loadSelectedFile() }
        .onChange(of: fileContents) { _ in
            guard fileContents != originalFileContents, isSaveEnabled else { return }
            hasUnsavedChanges = true
        }
        .onChange(of: displayMode) { newValue in
            if !isMarkdown && newValue != .edit {
                displayMode = .edit
            }
        }
    }

    private var modePicker: some View {
        Picker("Display Mode", selection: $displayMode) {
            ForEach(EditorDisplayMode.allCases) { mode in
                Text(mode.label)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .disabled(project.selectedFile == nil || !isMarkdown)
    }

    @ViewBuilder
    private var mainContent: some View {
        if let errorMessage = loadError {
            Text(errorMessage)
                .font(.system(size: theme.typography.fontSize - 1,
                              weight: .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(textColor.opacity(0.8))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else if project.selectedFile == nil {
            Text("Select a file from the navigator to view its contents.")
                .font(.system(size: theme.typography.fontSize - 1,
                              weight: .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(textColor.opacity(0.8))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            switch displayMode {
            case .edit:
                editorView
            case .preview:
                previewView
            case .split:
                splitView
            }
        }
    }

    private var editorView: some View {
        TextEditor(text: $fileContents)
            .font(.system(size: theme.typography.fontSize,
                          weight: .regular,
                          design: theme.typography.useMonospace ? .monospaced : .default))
            .foregroundColor(textColor)
            .scrollContentBackground(.hidden)
            .background(editorBackground)
            .padding(.top, -8)
    }

    @ViewBuilder
    private var previewView: some View {
        if isMarkdown {
            ScrollView {
                Text(markdownAttributedString)
                    .font(.system(size: theme.typography.fontSize,
                                  weight: .regular,
                                  design: theme.typography.useMonospace ? .monospaced : .default))
                    .foregroundStyle(markdownTextColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(editorBackground)
        } else {
            Text("Markdown preview is available for .md files.")
                .font(.system(size: theme.typography.fontSize - 1,
                              weight: .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(textColor.opacity(0.8))
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(editorBackground)
        }
    }

    private var splitView: some View {
        GeometryReader { proxy in
            let dividerHeight: CGFloat = 1
            let spacing: CGFloat = 12
            let contentHeight = max(0, proxy.size.height - spacing - dividerHeight)
            let sectionHeight = contentHeight / 2

            VStack(spacing: spacing) {
                editorView
                    .frame(height: sectionHeight)

                Divider()
                    .overlay(textColor.opacity(0.2))
                    .frame(height: dividerHeight)

                previewView
                    .frame(height: sectionHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var editorBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(textColor.opacity(theme.currentColorScheme == .dark ? 0.05 : 0.08))
    }

    private var markdownTextColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 210 / 255, green: 205 / 255, blue: 228 / 255)
            : Color(red: 65 / 255, green: 68 / 255, blue: 82 / 255)
    }

    private var saveButton: some View {
        Button(action: { saveFile() }) {
            Text("Save")
                .font(.system(size: theme.typography.fontSize,
                              weight: .semibold,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(saveButtonBackground)
                .foregroundStyle(saveButtonForeground)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .disabled(!isSaveEnabled || !hasUnsavedChanges)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 12)
    }

    private var saveButtonBackground: Color {
        guard isSaveEnabled, hasUnsavedChanges else {
            return textColor.opacity(0.1)
        }

        return theme.primaryAccentColor.opacity(theme.currentColorScheme == .dark ? 0.3 : 0.4)
    }

    private var saveButtonForeground: Color {
        guard isSaveEnabled, hasUnsavedChanges else {
            return textColor.opacity(0.5)
        }

        return theme.currentColorScheme == .dark ? .white : .black
    }

    private var isSaveEnabled: Bool {
        project.selectedFile != nil && project.projectFolderURL != nil
    }

    private var headerSubtitle: String {
        guard let filename = project.selectedFile else {
            return "No file selected"
        }

        let indicator = hasUnsavedChanges ? "• " : ""
        return "\(indicator)Currently editing: \(filename)"
    }

    private func loadSelectedFile() {
        guard let filename = project.selectedFile else {
            originalFileContents = ""
            fileContents = ""
            hasUnsavedChanges = false
            loadError = nil
            displayMode = .edit
            return
        }

        guard let folderURL = project.projectFolderURL else {
            originalFileContents = ""
            fileContents = ""
            hasUnsavedChanges = false
            loadError = "Project folder unavailable. Unable to load \(filename)."
            displayMode = .edit
            return
        }

        let fileURL = folderURL.appendingPathComponent(filename)

        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            originalFileContents = contents
            fileContents = contents
            hasUnsavedChanges = false
            loadError = nil

            if !isMarkdown {
                displayMode = .edit
            }
        } catch {
            originalFileContents = ""
            fileContents = ""
            hasUnsavedChanges = false
            loadError = "Failed to load \(filename): \(error.localizedDescription)"
            displayMode = .edit
        }
    }

    private func saveFile() {
        guard let filename = project.selectedFile,
              let folderURL = project.projectFolderURL else { return }

        let fileURL = folderURL.appendingPathComponent(filename)

        do {
            try fileContents.write(to: fileURL, atomically: true, encoding: .utf8)
            loadError = nil
            originalFileContents = fileContents
            hasUnsavedChanges = false
        } catch {
            loadError = "Failed to save \(filename): \(error.localizedDescription)"
        }
    }

    private enum EditorDisplayMode: String, CaseIterable, Identifiable {
        case edit
        case preview
        case split

        var id: String { rawValue }

        var label: String {
            switch self {
            case .edit:
                return "📝 Edit"
            case .preview:
                return "👁 Preview"
            case .split:
                return "🧿 Split"
            }
        }
    }
}

/*
#Preview {
    CodeEditorView()
        .frame(width: 600, height: 400)
        .environmentObject(ThemeManager())
        .environmentObject(
            ProjectState(
                openFilePaths: ["README.md"],
                selectedFile: "README.md",
                projectFolderURL: URL(fileURLWithPath: "/tmp")
            )
        )
}
*/
