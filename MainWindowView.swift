import SwiftUI
import AppKit

struct MainWindowView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var projectState: ProjectState
    @State private var isShowingSettings = false
    @State private var isShowingProjectPicker = false

    private enum Layout {
        static let sidebarWidth: CGFloat = 240
        static let inspectorWidth: CGFloat = 320
        static let paneCornerRadius: CGFloat = 12
        static let panePadding: CGFloat = 16
    }

    private var backgroundColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 18 / 255, green: 20 / 255, blue: 26 / 255)
            : Color(red: 236 / 255, green: 238 / 255, blue: 242 / 255)
    }

    private var paneBackgroundColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 32 / 255, green: 35 / 255, blue: 43 / 255)
            : Color(red: 252 / 255, green: 253 / 255, blue: 255 / 255)
    }

    private var dividerColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 58 / 255, green: 62 / 255, blue: 73 / 255)
            : Color(red: 203 / 255, green: 208 / 255, blue: 220 / 255)
    }

    private var titleColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 182 / 255, green: 189 / 255, blue: 204 / 255)
            : Color(red: 53 / 255, green: 60 / 255, blue: 75 / 255)
    }

    private var subtitleColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 123 / 255, green: 132 / 255, blue: 149 / 255)
            : Color(red: 105 / 255, green: 115 / 255, blue: 134 / 255)
    }

    private var specSidebarSubtitle: String {
        if projectState.specSections.isEmpty {
            return "No spec loaded"
        }

        return projectState.activeSpecSection ?? "Choose a spec section"
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar(title: "File Navigator", subtitle: projectState.selectedFile ?? "No file selected")
                .frame(width: Layout.sidebarWidth)

            divider

            contentPane(title: "Code Editor",
                        subtitle: projectState.selectedFile.map { "Editing \($0)" }
                            ?? "Open a file to start editing")

            divider

            sidebar(title: "Spec Sheet",
                    subtitle: specSidebarSubtitle)
                .frame(width: Layout.inspectorWidth)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .environment(\.colorScheme, theme.currentColorScheme)
        .toolbar(content: {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { isShowingProjectPicker = true }) {
                    Image(systemName: "folder.badge.plus")
                        .symbolRenderingMode(.hierarchical)
                }
                .help("Open Project Folder")

                Button(action: { isShowingSettings.toggle() }) {
                    Image(systemName: "gearshape.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .help("Open Settings")
            }
        })
        .sheet(isPresented: $isShowingSettings) {
            SettingsPanelView(theme: theme)
        }
        .sheet(isPresented: $isShowingProjectPicker) {
            ProjectPickerView()
                .environmentObject(projectState)
        }
        .onAppear {
            if let window = NSApplication.shared.windows.first {
                WindowStateManager.restore(for: window)
            }

            if projectState.openFilePaths.isEmpty {
                isShowingProjectPicker = true
            }
        }
        .onChange(of: projectState.openFilePaths) { newValue in
            if newValue.isEmpty {
                isShowingProjectPicker = true
            } else {
                isShowingProjectPicker = false
            }
        }
        .onDisappear {
            if let window = NSApplication.shared.windows.first {
                WindowStateManager.save(window: window)
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(width: 1)
    }

    private func sidebar(title: String, subtitle: String) -> some View {
        placeholderPane(title: title, subtitle: subtitle)
    }

    private func contentPane(title: String, subtitle: String) -> some View {
        placeholderPane(title: title, subtitle: subtitle)
            .frame(maxWidth: .infinity)
    }

    private func placeholderPane(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: theme.typography.fontSize + 2,
                              weight: .semibold,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(theme.primaryAccentColor)

            Text(subtitle)
                .font(.system(size: theme.typography.fontSize,
                              weight: .regular,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(subtitleColor)

            Spacer()
        }
        .padding(Layout.panePadding)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Layout.paneCornerRadius, style: .continuous)
                .fill(paneBackgroundColor)
        )
        .padding(.vertical, Layout.panePadding)
    }
}

/*
#Preview {
    MainWindowView()
        .frame(width: 1200, height: 700)
        .environmentObject(ThemeManager())
        .environmentObject(
            ProjectState(
                openFilePaths: ["App.swift", "ThemeManager.swift"],
                selectedFile: "App.swift",
                activeSpecSection: "Overview"
            )
        )
}
*/
