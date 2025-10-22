import SwiftUI

struct FileTreeView: View {
    @EnvironmentObject private var theme: ThemeManager

    private var backgroundColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 54 / 255, green: 71 / 255, blue: 105 / 255)
            : Color(red: 212 / 255, green: 223 / 255, blue: 246 / 255)
    }

    @EnvironmentObject private var project: ProjectState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("File Tree")
                .font(.system(size: theme.typography.fontSize,
                              weight: .semibold,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(theme.primaryAccentColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(project.openFilePaths, id: \.self) { filePath in
                    fileRow(for: filePath)
                }

                if project.openFilePaths.isEmpty {
                    Text("No files open")
                        .font(.system(size: theme.typography.fontSize - 1,
                                      weight: .regular,
                                      design: theme.typography.useMonospace ? .monospaced : .default))
                        .foregroundStyle(placeholderColor)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(width: 240, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
    }

    private var placeholderColor: Color {
        theme.currentColorScheme == .dark
            ? Color.white.opacity(0.4)
            : Color(red: 105 / 255, green: 116 / 255, blue: 141 / 255)
    }

    @ViewBuilder
    private func fileRow(for filePath: String) -> some View {
        let isSelected = project.selectedFile == filePath
        let iconName = iconNameForFile(filePath)

        Label {
            Text(filePath)
                .font(.system(size: theme.typography.fontSize - 1,
                              weight: isSelected ? .semibold : .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
        } icon: {
            Image(systemName: iconName)
        }
            .font(.system(size: theme.typography.fontSize - 1,
                          weight: isSelected ? .semibold : .regular,
                          design: theme.typography.useMonospace ? .monospaced : .default))
            .foregroundStyle(isSelected ? theme.primaryAccentColor : rowTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? selectionBackground : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                project.selectedFile = filePath
            }
    }

    private func iconNameForFile(_ file: String) -> String {
        if file.hasSuffix(".swift") {
            return "chevron.left.slash.chevron.right"
        } else if file.hasSuffix(".json") {
            return "curlybraces"
        } else if file.hasSuffix(".md") {
            return "doc.plaintext"
        } else {
            return "doc"
        }
    }

    private var rowTextColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 202 / 255, green: 210 / 255, blue: 224 / 255)
            : Color(red: 60 / 255, green: 70 / 255, blue: 92 / 255)
    }

    private var selectionBackground: Color {
        theme.currentColorScheme == .dark
            ? theme.primaryAccentColor.opacity(0.15)
            : theme.primaryAccentColor.opacity(0.25)
    }
}

/*
#Preview {
    FileTreeView()
        .frame(height: 400)
        .environmentObject(ThemeManager())
        .environmentObject(
            ProjectState(
                openFilePaths: ["App.swift", "Theme.swift"],
                selectedFile: "App.swift"
            )
        )
}
*/
