import SwiftUI

struct ChatView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Who is Andres The Designer?", sender: .user),
        ChatMessage(
            text: "Andres The Designer is a rising digital product designer known for blending thoughtful UX with bold, expressive visuals. He regularly shares case studies that highlight motion, tactile interfaces, and immersive layouts.",
            sender: .assistant
        )
    ]
    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 28) {
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
                    .padding(.vertical, 32)
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

            bottomControls
                .frame(maxWidth: 680)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }

    private func bubbleView(for message: ChatMessage) -> some View {
        VStack(alignment: message.sender == .assistant ? .leading : .trailing, spacing: 10) {
            Text(message.text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(message.sender == .assistant ? .white : Color(hex: "#1b1b1b"))
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(
                    bubbleShape(for: message.sender)
                        .fill(message.sender == .assistant ? Color.gray.opacity(0.35) : Color(hex: "#B9FB9D"))
                )
                .frame(maxWidth: 520, alignment: message.sender == .assistant ? .leading : .trailing)
                .id(message.id)

            if message.sender == .assistant {
                HStack(spacing: 12) {
                    badge(text: "GPT-4.0")

                    Button(action: {}) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.72))
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
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.8))
            .clipShape(Capsule())
    }

    private var bottomControls: some View {
        HStack(spacing: 16) {
            HStack(spacing: 12) {
                TextField("Send a message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...3)
                    .foregroundColor(.white)
                    .tint(.white.opacity(0.9))

                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white.opacity(0.8))
                }

                Button(action: {}) {
                    Text("GPT-4.0")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Capsule())
                }

                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white.opacity(0.85))
                }

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppTheme.card.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 20)
            )

            Button(action: regenerateResponse) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Regenerate")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.88))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppTheme.card.opacity(0.75))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                )
            }
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(text: trimmed, sender: .user))
        inputText = ""
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
