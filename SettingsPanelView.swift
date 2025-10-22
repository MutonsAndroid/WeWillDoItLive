import SwiftUI

struct SettingsPanelView: View {
    @ObservedObject var theme: ThemeManager

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle(isOn: Binding(
                    get: { theme.currentColorScheme == .dark },
                    set: { theme.currentColorScheme = $0 ? .dark : .light }
                )) {
                    Text("Dark Mode")
                }

                Slider(value: Binding(
                    get: { Double(theme.typography.fontSize) },
                    set: {
                        theme.typography = .init(fontSize: CGFloat($0),
                                                 useMonospace: theme.typography.useMonospace)
                    }
                ), in: 8...22, step: 1) {
                    Text("Font Size")
                }
                Text("\(Int(theme.typography.fontSize)) pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle("Use Monospace", isOn: Binding(
                    get: { theme.typography.useMonospace },
                    set: {
                        theme.typography = .init(fontSize: theme.typography.fontSize,
                                                 useMonospace: $0)
                    }
                ))
            }
        }
        .padding()
        .frame(width: 320)
    }
}

/*
#Preview {
    SettingsPanelView(theme: ThemeManager())
}
*/
