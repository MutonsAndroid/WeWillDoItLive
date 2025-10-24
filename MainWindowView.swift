import SwiftUI

struct MainWindowView: View {
    @StateObject var theme = AppTheme()
    @State private var projectRoot: FileNode? = {
        let path = "/Users/DutDev/Code/WeWillDoItLive"
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        var root = FileNode.buildTree(from: url)
        root.isExpanded = true
        return root
    }()
    @State private var selectedFileID: UUID?

    var body: some View {
        HStack(spacing: 0) {
            FileTreeView(root: $projectRoot, selectedID: $selectedFileID)
                .frame(width: 240)
                .padding(8)

            verticalDivider

            ChatView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.background)

            verticalDivider

            SpecDeckView(theme: theme)
                .padding(8)
                .frame(width: 360)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
        .frame(minWidth: 900, minHeight: 500)
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
}
