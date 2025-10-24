import SwiftUI

struct CodexTaskView: View {
    @EnvironmentObject private var engine: OpenCodeEngine
    let task: CodexTask

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(task.title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(task.description)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Button(action: runTask) {
                Label("Run Task", systemImage: "play.circle.fill")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.panelBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                )
        )
    }

    private func runTask() {
        engine.run(command: task.codeSnippet)
    }
}
