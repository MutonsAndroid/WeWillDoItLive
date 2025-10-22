import SwiftUI

struct SpecViewerView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var project: ProjectState

    private var backgroundColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 68 / 255, green: 58 / 255, blue: 96 / 255)
            : Color(red: 233 / 255, green: 226 / 255, blue: 248 / 255)
    }

    private var sections: [SpecSection] {
        project.specSections
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spec Viewer")
                .font(.system(size: theme.typography.fontSize,
                              weight: .semibold,
                              design: theme.typography.useMonospace ? .monospaced : .default))
                .foregroundStyle(theme.primaryAccentColor)

            VStack(alignment: .leading, spacing: 6) {
                if sections.isEmpty {
                    Text("No spec sections available.")
                        .font(.system(size: theme.typography.fontSize - 1,
                                      weight: .regular,
                                      design: theme.typography.useMonospace ? .monospaced : .default))
                        .foregroundStyle(rowTextColor.opacity(0.75))
                        .padding(.vertical, 8)
                } else {
                    ForEach(sections) { section in
                        sectionRow(for: section)
                    }
                }
            }

            Divider()
                .overlay(theme.primaryAccentColor.opacity(0.2))

            contentView
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .frame(width: 320, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(backgroundColor)
    }

    @ViewBuilder
    private func sectionRow(for section: SpecSection) -> some View {
        let isSelected = project.activeSpecSection == section.title

        Text(section.title)
            .font(.system(size: theme.typography.fontSize - 1,
                          weight: isSelected ? .semibold : .regular,
                          design: theme.typography.useMonospace ? .monospaced : .default))
            .foregroundStyle(isSelected ? theme.primaryAccentColor : rowTextColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? selectionBackground : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                project.activeSpecSection = section.title
            }
    }

    private var rowTextColor: Color {
        theme.currentColorScheme == .dark
            ? Color(red: 210 / 255, green: 205 / 255, blue: 228 / 255)
            : Color(red: 70 / 255, green: 60 / 255, blue: 92 / 255)
    }

    private var selectionBackground: Color {
        theme.currentColorScheme == .dark
            ? theme.primaryAccentColor.opacity(0.2)
            : theme.primaryAccentColor.opacity(0.25)
    }

    private var contentView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.system(size: theme.typography.fontSize + 4,
                                              weight: .semibold,
                                              design: theme.typography.useMonospace ? .monospaced : .default))
                                .foregroundStyle(theme.primaryAccentColor)
                                .id(section.title)

                            Text(section.content)
                                .font(.system(size: theme.typography.fontSize,
                                              weight: .regular,
                                              design: theme.typography.useMonospace ? .monospaced : .default))
                                .foregroundStyle(rowTextColor)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    if sections.isEmpty {
                        Text("Select a section to view its details.")
                            .font(.system(size: theme.typography.fontSize - 1,
                                          weight: .regular,
                                          design: theme.typography.useMonospace ? .monospaced : .default))
                            .foregroundStyle(rowTextColor.opacity(0.7))
                    }
                }
            }
            .onChange(of: project.activeSpecSection) { newValue in
                guard let target = newValue,
                      sections.contains(where: { $0.title == target }) else { return }
                withAnimation {
                    proxy.scrollTo(target, anchor: .top)
                }
            }
            .onAppear {
                if let target = project.activeSpecSection,
                   sections.contains(where: { $0.title == target }) {
                    proxy.scrollTo(target, anchor: .top)
                }
            }
        }
    }
}

/*
#Preview {
    SpecViewerView()
        .frame(height: 400)
        .environmentObject(ThemeManager())
        .environmentObject(
            ProjectState(
                activeSpecSection: "1.0 Introduction",
                specSections: [
                    SpecSection(title: "1.0 Introduction", content: "Intro content"),
                    SpecSection(title: "2.0 Target Users", content: "Users content")
                ]
            )
        )
}
*/
