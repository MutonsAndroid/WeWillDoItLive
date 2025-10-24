import SwiftUI

struct HistoryView: View {
    @ObservedObject var history: OpenCodeHistory
    var onSelect: (String) -> Void

    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search history...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            List(filteredItems) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.command)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                        Spacer()
                        Text(item.interpreter)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Text(item.timestamp.formatted(date: .numeric, time: .standard))
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(item.outputPreview)
                        .font(.caption.monospaced())
                        .lineLimit(2)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(item.command)
                }
            }
            .listStyle(.inset)

            Button("Clear History") {
                history.clear()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.alertRed)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 16)
        .background(AppTheme.panelBackground)
    }

    private var filteredItems: [OpenCodeHistoryItem] {
        guard !searchText.isEmpty else { return history.items }
        return history.items.filter { item in
            item.command.localizedCaseInsensitiveContains(searchText)
                || item.outputPreview.localizedCaseInsensitiveContains(searchText)
        }
    }
}
