import SwiftUI

struct SpecDeckView: View {
    @ObservedObject var theme: AppTheme
    @StateObject private var viewModel = SpecDeckViewModel()

    private var accentColor: Color { theme.accentColor }

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading, spacing: 18) {
                header
                cardsStack
                Spacer(minLength: 0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.card.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.04), lineWidth: 1)
                    )
                    .shadow(color: accentColor.opacity(0.18), radius: 28, x: 0, y: 18)
            )

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

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Spec Execution Deck")
                        .font(theme.sectionTitleFont)
                        .foregroundColor(accentColor)

                    Text("Monitor Agent OS specs as they execute")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor.opacity(0.65))
                }

                Spacer()

                Button(action: viewModel.toggleHistory) {
                    Label("Spec History", systemImage: "clock.arrow.circlepath")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(accentColor.opacity(0.16))
                                .overlay(
                                    Capsule()
                                        .stroke(accentColor.opacity(0.32), lineWidth: 1)
                                )
                        )
                        .foregroundColor(accentColor)
                }
                .buttonStyle(.plain)
            }

            theme.divider
                .opacity(0.3)
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
                .font(theme.bodyFont.weight(.semibold))
                .foregroundColor(theme.textColor.opacity(0.85))

            Text("New Agent OS specs will automatically surface here as they are generated.")
                .font(theme.bodyFont)
                .foregroundColor(theme.textColor.opacity(0.65))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
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
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    badge(text: task.model.uppercased(), icon: "bolt.fill")

                    badge(text: task.statusLabel, icon: task.statusIcon)
                        .foregroundStyle(task.statusColor.opacity(0.75))
                }
            }

            Spacer()

            if task.progress >= 100 {
                Toggle(isOn: $isChecked) {
                    Text("Complete")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
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
            .foregroundColor(.white.opacity(0.78))
            .multilineTextAlignment(.leading)
    }

    private var validation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Validation")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.55))

            Text(task.validation)
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.68))
        }
    }

    private var progress: some View {
        HStack {
            Text(task.progressText)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
            Spacer()
        }
    }

    private var progressOverlay: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.9),
                                accentColor.opacity(0.65)
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
            .fill(Color(hex: "#2A2B2F").opacity(0.94))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.14), radius: 18, x: 0, y: 12)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.18))
                .overlay(
                    Circle()
                        .stroke(accentColor.opacity(0.35), lineWidth: 1)
                )
            Text(task.avatarInitials)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(accentColor)
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
        .foregroundColor(.white.opacity(0.75))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.08))
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
        case .pending: Color.orange
        case .running: Color.blue
        case .complete: Color.green
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
                    .foregroundColor(.white.opacity(0.85))

                Spacer()

                Button(action: closeAction) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.08))
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
                iconColor: Color.green.opacity(0.85)
            )

            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(width: 260, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .shadow(color: accentColor.opacity(0.2), radius: 22, x: 12, y: 20)
    }

    private func historySection(title: String, tasks: [SpecTask], icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.55))

            if tasks.isEmpty {
                Text("None")
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
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
                                .foregroundColor(.white.opacity(0.86))
                                .lineLimit(2)

                            Text(task.progressText)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.45))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                    )
                }
            }
        }
    }
}
