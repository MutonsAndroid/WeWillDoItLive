import SwiftUI

struct ChatView: View {
    @EnvironmentObject var engine: OpenCodeEngine
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Who is Andres The Designer?", sender: .user),
        ChatMessage(
            text: "Andres The Designer is a rising digital product designer known for blending thoughtful UX with bold, expressive visuals. He regularly shares case studies that highlight motion, tactile interfaces, and immersive layouts.",
            sender: .assistant
        )
    ]
    @State private var messageText: String = ""
    @State private var selectedModel: ChatModel = .gpt4

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        ForEach(messages) { message in
                            HStack {
                                if message.sender == .assistant {
                                    bubbleView(for: message)
                                    Spacer(minLength: 0)
                                } else {
                                    Spacer(minLength: 0)
                                    bubbleView(for: message)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .padding(.bottom, 200)
                    .frame(maxWidth: 680)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: messages.count) { _ in
                    guard let last = messages.last else { return }
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            VStack(spacing: 0) {
                Spacer()
                chatControls
                    .frame(maxWidth: 680)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(AppTheme.background)
    }

    private func bubbleView(for message: ChatMessage) -> some View {
        VStack(alignment: message.sender == .assistant ? .leading : .trailing, spacing: 10) {
            Text(message.text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(message.sender == .assistant ? AppTheme.textPrimary : AppTheme.background)
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(
                    bubbleShape(for: message.sender)
                        .fill(
                            message.sender == .assistant
                                ? AppTheme.chatBubbleAI
                                : AppTheme.accentPrimary.opacity(0.9)
                        )
                        .overlay(
                            bubbleShape(for: message.sender)
                                .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                        )
                )
                .frame(maxWidth: 520, alignment: message.sender == .assistant ? .leading : .trailing)
                .id(message.id)

            if message.sender == .assistant {
                HStack(spacing: 12) {
                    badge(text: "GPT-4.0")

                    Button(action: {}) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: 520, alignment: .leading)
                .padding(.horizontal, 8)
            }
        }
    }

    private func bubbleShape(for sender: Sender) -> AnyShape {
        if sender == .assistant {
            return AnyShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        } else {
            return AnyShape(UserBubbleShape())
        }
    }

    private func badge(text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(AppTheme.accentCoolBlue.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.accentCoolBlue.opacity(0.6), lineWidth: 1)
                    )
            )
            .clipShape(Capsule())
    }

    private var chatControls: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(spacing: 8) {
                ModelSelectorView(selectedModel: $selectedModel)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedModel)
                    .transition(.move(edge: .bottom))
                RegenerateButton(action: regenerateResponse)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.bottom, 6)

            InputBarView(
                messageText: $messageText,
                isSendDisabled: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                sendMessage: sendMessage
            )
        }
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(text: trimmed, sender: .user))
        engine.run(command: trimmed)
        messageText = ""
    }

    private func regenerateResponse() {
        messages.append(
            ChatMessage(
                text: "Here’s a fresh take: Andres champions meaningful motion systems and relies on narrative-driven design. He keeps collaboration transparent through in-progress walkthroughs and interactive prototypes.",
                sender: .assistant
            )
        )
    }
}

private struct UserBubbleShape: Shape {
    private let radius: CGFloat = 26

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let topLeft = radius
        let topRight = radius
        let bottomLeft = radius
        let bottomRight: CGFloat = 8

        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}

private struct AnyShape: Shape {
    private let buildPath: @Sendable (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        buildPath = { rect in
            var path = Path()
            path.addPath(wrapped.path(in: rect))
            return path
        }
    }

    func path(in rect: CGRect) -> Path {
        buildPath(rect)
    }
}

private enum ChatModel: String, CaseIterable, Identifiable {
    case gpt4 = "GPT-4.0"
    case gpt4Mini = "GPT-4 Turbo"
    case gpt35 = "GPT-3.5"

    var id: String { rawValue }
}

private struct ModelSelectorView: View {
    @Binding var selectedModel: ChatModel
    @State private var isExpanded = false
    private let controlHeight: CGFloat = 40

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if isExpanded {
                VStack(alignment: .trailing, spacing: 6) {
                    ForEach(ChatModel.allCases) { model in
                        Button {
                            selectedModel = model
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                isExpanded = false
                            }
                        } label: {
                            Text(model.rawValue)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(model == selectedModel ? AppTheme.accentTeal : AppTheme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.panelBackground.opacity(model == selectedModel ? 0.9 : 0.5))
                                        .overlay(
                                            Capsule()
                                                .stroke(AppTheme.border.opacity(model == selectedModel ? 1.0 : 0.7), lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .offset(y: -(controlHeight + 8))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "dial.low.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(selectedModel.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(height: controlHeight)
                .background(
                    Capsule()
                        .fill(AppTheme.panelBackground)
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                        .shadow(color: AppTheme.panelBackground.opacity(0.45), radius: 22, x: 0, y: 18)
                )
            }
            .buttonStyle(.plain)
        }
        .zIndex(isExpanded ? 1 : 0)
    }
}

private struct RegenerateButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text("Regenerate")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppTheme.panelBackground)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .shadow(color: AppTheme.panelBackground.opacity(0.35), radius: 22, x: 0, y: 18)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct InputBarView: View {
    @Binding var messageText: String
    var isSendDisabled: Bool
    var sendMessage: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "mic.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            TextField("Send a message", text: $messageText, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1...4)
                .tint(AppTheme.accentTeal)
                .onSubmit(sendMessage)

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.accentPrimary)
            }
            .keyboardShortcut(.return, modifiers: [])
            .disabled(isSendDisabled)
            .opacity(isSendDisabled ? 0.4 : 1.0)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppTheme.panelBackground)
                .overlay(
                    Capsule()
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: AppTheme.panelBackground.opacity(0.35), radius: 26, x: 0, y: 20)
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}
