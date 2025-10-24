import SwiftUI

struct SpecDeckView: View {
    @StateObject private var viewModel = SpecDeckViewModel()

    private let accentColor: Color = AppTheme.accentCoolBlue

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading, spacing: 18) {
                header
                cardsStack
                codexTasksSection
                Spacer(minLength: 0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: accentColor.opacity(0.18), radius: 28, x: 0, y: 18)
            )
            .foregroundColor(AppTheme.textPrimary)

            if viewModel.isHistoryVisible {
                SpecHistoryDrawer(
                    completed: viewModel.completed,
                    remaining: viewModel.deck,
                    accentColor: accentColor,
                    closeAction: viewModel.toggleHistory
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .zIndex(1)
                .padding(.leading, 12)
            }
        }
        .animation(.spring(response: 0.48, dampingFraction: 0.86), value: viewModel.deck)
        .animation(.spring(response: 0.48, dampingFraction: 0.86), value: viewModel.isHistoryVisible)
    }

    private var codexTasks: [CodexTask] {
        viewModel.deck.map { CodexTask(specTask: $0) }
    }

    @ViewBuilder
    private var codexTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Codex Tasks")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            if codexTasks.isEmpty {
                Text("All Codex tasks are synced with OpenCode.")
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                ForEach(Array(codexTasks.prefix(3))) { task in
                    CodexTaskView(task: task)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Spec Execution Deck")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(accentColor)

                    Text("Monitor Agent OS specs as they execute")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Button(action: viewModel.toggleHistory) {
                    Label("Spec History", systemImage: "clock.arrow.circlepath")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppTheme.accentTeal.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.accentTeal.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(AppTheme.accentTeal)
                }
                .buttonStyle(.plain)
            }

            Rectangle()
                .fill(AppTheme.border.opacity(0.6))
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var cardsStack: some View {
        if viewModel.deck.isEmpty {
            emptyState
        } else {
            ZStack(alignment: .topLeading) {
                ForEach(Array(viewModel.deck.enumerated()), id: \.element.stableKey) { index, task in
                    SpecCardView(
                        task: task,
                        accentColor: accentColor,
                        onConfirm: { viewModel.confirmCompletion(for: task) }
                    )
                    .padding(.horizontal, CGFloat(index) * 1.5)
                    .padding(.top, CGFloat(index) * 22)
                    .scaleEffect(1.0 - CGFloat(index) * 0.025)
                    .opacity(index >= 3 ? 0 : 1)
                    .zIndex(Double(viewModel.deck.count - index))
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.25)),
                        removal: .move(edge: .top).combined(with: .opacity).animation(.easeInOut(duration: 0.35))
                    ))
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.top, 6)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All specs are complete.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Text("New Agent OS specs will automatically surface here as they are generated.")
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.background.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

private struct SpecCardView: View {
    let task: SpecTask
    let accentColor: Color
    let onConfirm: () -> Void

    @State private var isChecked: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            description
            validation
            progress
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .overlay(progressOverlay, alignment: .bottomLeading)
        .onChange(of: task.stableKey) { _ in
            isChecked = false
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 8) {
                    badge(text: task.model.uppercased(), icon: "bolt.fill")

                    badge(text: task.statusLabel, icon: task.statusIcon)
                        .foregroundStyle(task.statusColor.opacity(0.9))
                }
            }

            Spacer()

            if task.progress >= 100 {
                Toggle(isOn: $isChecked) {
                    Text("Complete")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.accentPrimary)
                }
                .toggleStyle(.checkbox)
                .onChange(of: isChecked) { newValue in
                    guard newValue else { return }
                    onConfirm()
                }
                .labelsHidden()
            }
        }
    }

    private var description: some View {
        Text(task.description)
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundColor(AppTheme.textSecondary)
            .multilineTextAlignment(.leading)
    }

    private var validation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Validation")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .textCase(.uppercase)
                .foregroundColor(AppTheme.textSecondary)

            Text(task.validation)
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(AppTheme.textSecondary.opacity(0.9))
        }
    }

    private var progress: some View {
        HStack {
            Text(task.progressText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
    }

    private var progressOverlay: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.border.opacity(0.3))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.accentPrimary.opacity(0.9),
                                AppTheme.accentTeal.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(min(task.progress / 100.0, 1.0))))
                    .animation(.easeInOut(duration: 0.4), value: task.progress)
            }
        }
        .frame(height: 6)
        .padding(.bottom, -3)
        .padding(.horizontal, -4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(AppTheme.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.border.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.14), radius: 18, x: 0, y: 12)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accentCoolBlue.opacity(0.18))
                .overlay(
                    Circle()
                        .stroke(AppTheme.accentCoolBlue.opacity(0.35), lineWidth: 1)
                )
            Text(task.avatarInitials)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.accentCoolBlue)
        }
        .frame(width: 34, height: 34)
    }

    private func badge(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
        }
        .foregroundColor(AppTheme.textSecondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(AppTheme.background.opacity(0.6))
        )
    }
}

private extension SpecTask {
    var progressText: String {
        "\(Int(progress.rounded()))%"
    }

    var avatarInitials: String {
        let components = (assignee ?? title).split(separator: " ")
        if components.count >= 2 {
            return components.prefix(2).map { String($0.prefix(1)).uppercased() }.joined()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        } else {
            return "AI"
        }
    }

    var statusLabel: String {
        switch status {
        case .pending: "Pending"
        case .running: "Running"
        case .complete: "Complete"
        }
    }

    var statusIcon: String {
        switch status {
        case .pending: "pause.circle.fill"
        case .running: "waveform.path.ecg"
        case .complete: "checkmark.seal.fill"
        }
    }

    var statusColor: Color {
        switch status {
        case .pending: AppTheme.warning
        case .running: AppTheme.accentCoolBlue
        case .complete: AppTheme.accentPrimary
        }
    }
}

struct SpecHistoryDrawer: View {
    let completed: [SpecTask]
    let remaining: [SpecTask]
    let accentColor: Color
    let closeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Spec History")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button(action: closeAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.textSecondary)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(AppTheme.background.opacity(0.7))
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }

            historySection(
                title: "Remaining",
                tasks: remaining,
                icon: "rectangle.stack",
                iconColor: accentColor.opacity(0.8)
            )

            historySection(
                title: "Completed",
                tasks: completed,
                icon: "checkmark.circle.fill",
                iconColor: AppTheme.accentPrimary.opacity(0.85)
            )

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 260, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.panel)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                )
        )
        .shadow(color: accentColor.opacity(0.2), radius: 22, x: 12, y: 20)
    }

    private func historySection(title: String, tasks: [SpecTask], icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .textCase(.uppercase)
                .foregroundColor(AppTheme.textSecondary)

            if tasks.isEmpty {
                Text("None")
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.6))
            } else {
                ForEach(tasks, id: \.stableKey) { task in
                    HStack(spacing: 10) {
                        Image(systemName: icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(iconColor)
                            .frame(width: 20)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(2)

                            Text(task.progressText)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.background.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}
