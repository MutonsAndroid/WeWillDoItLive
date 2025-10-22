import SwiftUI

struct MainWindowView: View {
    @StateObject var theme = AppTheme()

    private let sampleFiles = [
        "AppDelegate.swift",
        "ContentView.swift",
        "Theme/AppTheme.swift",
        "Services/GitManager.swift",
        "Utilities/SessionManager.swift"
    ]

    private let sampleCode = """
    class NovaForgeIDE {
        constructor(private projectPath: string, private assistant: AssistantClient) {}

        async boot(): Promise<void> {
            await this.loadWorkspace();
            this.registerShortcuts();
        }

        private async loadWorkspace(): Promise<void> {
            const files = await FileSystem.discover(this.projectPath, { extensions: [".ts", ".swift"] });
            WorkspaceState.sync(files);
        }

        private registerShortcuts(): void {
            ShortcutManager.bind("ctrl+shift+f", () => this.assistant.searchInContext());
            ShortcutManager.bind("ctrl+enter", () => this.assistant.applySuggestion());
        }
    }

    export const ide = new NovaForgeIDE("/Users/dev/Projects/Nova", new AssistantClient());
    """

    private let sampleAIResponse = """
    NovaForge IDE detected a SwiftUI layout update.
    - Consider extracting shared pane metrics into a layout config type.
    - Add syntax highlighting by pairing the editor pane with a tokenized renderer.
    - Persist AI assistant transcripts so users can revisit prior suggestions.
    """

    var body: some View {
        ZStack {
            theme.windowBackground
                .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    theme.accentColor.opacity(0.35),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 80,
                endRadius: 520
            )
            .blur(radius: 90)
            .ignoresSafeArea()

            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 94 / 255, green: 51 / 255, blue: 150 / 255).opacity(0.28),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 60,
                endRadius: 520
            )
            .blur(radius: 110)
            .ignoresSafeArea()

            HStack(spacing: 0) {
                fileListPane
                    .frame(width: 200)
                    .frame(maxHeight: .infinity)

                verticalDivider

                editorPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                verticalDivider

                assistantPane
                    .frame(width: 300)
                    .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 900, minHeight: 500)
    }

    private var fileListPane: some View {
        paneContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text("Files")
                    .font(theme.sectionTitleFont)
                    .foregroundColor(theme.accentColor)

                theme.divider
                    .opacity(0.35)

                ForEach(sampleFiles, id: \.self) { file in
                    Text(file)
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor.opacity(0.9))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(theme.dividerColor.opacity(0.25))
                                .blur(radius: 0.5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(theme.dividerColor.opacity(0.35), lineWidth: 0.5)
                        )
                }

                Spacer()
            }
        }
    }

    private var editorPane: some View {
        paneContainer(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Code Editor")
                    .font(theme.sectionTitleFont)
                    .foregroundColor(theme.accentColor)
                    .padding(.top, 28)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 18)

                theme.divider
                    .opacity(0.5)
                    .padding(.horizontal, 28)

                ScrollView {
                    Text(sampleCode)
                        .font(theme.codeFont)
                        .foregroundColor(theme.textColor)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .textSelection(.enabled)
                        .padding(28)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(theme.editorBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(theme.dividerColor.opacity(0.4), lineWidth: 1)
                                )
                                .shadow(color: theme.accentColor.opacity(0.18), radius: 14, x: 0, y: 12)
                        )
                        .padding(.horizontal, 28)
                        .padding(.top, 20)
                }
                .padding(.bottom, 32)
            }
        }
    }

    private var assistantPane: some View {
        paneContainer {
            VStack(alignment: .leading, spacing: 18) {
                Text("AI Assistant")
                    .font(theme.sectionTitleFont)
                    .foregroundColor(theme.accentColor)

                theme.divider
                    .opacity(0.35)

                Text("Recent Output")
                    .font(theme.bodyFont)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.textColor.opacity(0.8))

                Text(sampleAIResponse)
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor.opacity(0.85))

                Spacer()
            }
        }
    }

    private var verticalDivider: some View {
        theme.divider
            .rotationEffect(.degrees(90))
            .frame(width: 1)
            .frame(maxHeight: .infinity)
            .opacity(0.45)
            .blur(radius: 0.6)
            .shadow(color: theme.accentColor.opacity(0.2), radius: 14)
    }

    @ViewBuilder
    private func paneContainer<Content: View>(
        padding: CGFloat = 24,
        alignment: Alignment = .topLeading,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 18 / 255, green: 10 / 255, blue: 34 / 255).opacity(0.55))
                .blur(radius: 26)

            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.panelBackground)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            theme.accentColor.opacity(0.32),
                            Color(red: 123 / 255, green: 73 / 255, blue: 167 / 255).opacity(0.18),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(theme.dividerColor.opacity(0.65), lineWidth: 1)
                )

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .padding(padding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadow(color: theme.accentColor.opacity(0.24), radius: 20, x: 0, y: 16)
    }
}
