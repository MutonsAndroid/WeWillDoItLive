import Foundation

enum Sender {
    case user, assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let sender: Sender
}
