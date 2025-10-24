import SwiftUI

struct MainWindowView: View {
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

            OpenCodeView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            verticalDivider

            SpecDeckView()
                .padding(8)
                .frame(width: 360)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(AppTheme.textPrimary)
        .background(AppTheme.background.ignoresSafeArea())
        .frame(minWidth: 900, minHeight: 500)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(AppTheme.border.opacity(0.6))
            .frame(width: 1)
            .frame(maxHeight: .infinity)
    }
}
