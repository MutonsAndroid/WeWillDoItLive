import SwiftUI
import UniformTypeIdentifiers

struct FileTreeView: View {
    @Binding var root: FileNode?
    @Binding var selectedID: UUID?

    @State private var searchText = ""
    @State private var showingImporter = false

    private var isFiltering: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 12) {
            header

            if let root,
               let filteredTree = root.filtered(using: searchText) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 6) {
                        FileTreeNodeView(
                            node: filteredTree,
                            level: 0,
                            isFiltering: isFiltering,
                            selectedID: selectedID,
                            onToggle: { toggleNode(id: $0) },
                            onSelect: { selectedID = $0 }
                        )
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if root != nil {
                noResults
            } else {
                placeholder
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppTheme.card)
        )
    }

    private var header: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white.opacity(0.42))

                TextField("Search files", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                    .disableAutocorrection(true)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )

            Button {
                showingImporter = true
            } label: {
                Image(systemName: "folder.badge.gear")
                    .imageScale(.medium)
                    .foregroundColor(.white.opacity(0.82))
                    .padding(9)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                    )
            }
            .buttonStyle(.plain)
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [UTType.folder]) { result in
                switch result {
                case .success(let url):
                    var newRoot = FileNode.buildTree(from: url)
                    newRoot.isExpanded = true
                    root = newRoot
                    selectedID = nil
                case .failure:
                    break
                }
            }
        }
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .foregroundColor(.white.opacity(0.4))
                .imageScale(.large)

            Text("Select a project to begin")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.top, 24)
    }

    private var noResults: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.4))
                .imageScale(.medium)

            Text("No matches found")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding(.top, 24)
    }

    private func toggleNode(id: UUID) {
        guard var root, toggleNode(in: &root, id: id) else { return }
        self.root = root
    }

    @discardableResult
    private func toggleNode(in node: inout FileNode, id: UUID) -> Bool {
        if node.id == id {
            node.isExpanded.toggle()
            return true
        }

        for index in node.children.indices {
            if toggleNode(in: &node.children[index], id: id) {
                return true
            }
        }

        return false
    }
}

private struct FileTreeNodeView: View {
    let node: FileNode
    let level: Int
    let isFiltering: Bool
    let selectedID: UUID?
    let onToggle: (UUID) -> Void
    let onSelect: (UUID) -> Void

    private var isSelected: Bool {
        selectedID == node.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                if node.isDirectory {
                    onToggle(node.id)
                }
                onSelect(node.id)
            } label: {
                HStack(spacing: 10) {
                    if node.isDirectory {
                        Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                            .foregroundColor(.white.opacity(0.45))
                    } else {
                        Image(systemName: "chevron.right")
                            .opacity(0)
                    }

                    Image(systemName: node.isDirectory ? "folder" : "doc.text")
                        .foregroundColor(node.isDirectory ? Color.white.opacity(0.75) : Color.white.opacity(0.55))

                    Text(node.name)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.18) : Color.clear)
                )
            }
            .padding(.leading, CGFloat(level) * 16)
            .buttonStyle(.plain)

            if node.isDirectory && (node.isExpanded || isFiltering) {
                ForEach(node.children) { child in
                    FileTreeNodeView(
                        node: child,
                        level: level + 1,
                        isFiltering: isFiltering,
                        selectedID: selectedID,
                        onToggle: onToggle,
                        onSelect: onSelect
                    )
                }
            }
        }
    }
}
