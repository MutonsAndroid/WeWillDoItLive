import SwiftUI

struct EnvEditorView: View {
    @Binding var config: OpenCodeConfig
    @State private var newKey: String = ""
    @State private var newValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Environment Variables")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(config.envVars.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(AppTheme.textSecondary)

                    Spacer()

                    TextField("Value", text: Binding(
                        get: { value },
                        set: { config.envVars[key] = $0; config.save() }
                    ))
                    .textFieldStyle(.roundedBorder)
                }
            }

            HStack(spacing: 8) {
                TextField("New Key", text: $newKey)
                    .textFieldStyle(.roundedBorder)
                TextField("New Value", text: $newValue)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    guard !newKey.isEmpty else { return }
                    config.envVars[newKey] = newValue
                    config.save()
                    newKey = ""
                    newValue = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
