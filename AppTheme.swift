import SwiftUI

final class AppTheme: ObservableObject {
    static let background = Color(hex: "#1b1b1b")
    static let card = Color(hex: "#232426")

    @Published var windowBackground: LinearGradient
    @Published var panelBackground: Color
    @Published var editorBackground: Color
    @Published var accentColor: Color
    @Published var textColor: Color
    @Published var dividerColor: Color

    @Published var bodyFont: Font
    @Published var codeFont: Font
    @Published var sectionTitleFont: Font

    init(
        windowBackground: LinearGradient = LinearGradient(
            gradient: Gradient(
                colors: [
                    Color(red: 33 / 255, green: 21 / 255, blue: 61 / 255),
                    Color(red: 16 / 255, green: 12 / 255, blue: 36 / 255),
                    Color(red: 9 / 255, green: 8 / 255, blue: 20 / 255)
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        panelBackground: Color = Color(red: 43 / 255, green: 26 / 255, blue: 67 / 255).opacity(0.6),
        editorBackground: Color = Color(red: 26 / 255, green: 17 / 255, blue: 45 / 255).opacity(0.7),
        accentColor: Color = Color(red: 111 / 255, green: 212 / 255, blue: 1.0),
        textColor: Color = Color.white.opacity(0.94),
        dividerColor: Color = Color(red: 111 / 255, green: 212 / 255, blue: 1.0).opacity(0.35),
        bodyFont: Font = .system(size: 13, weight: .regular, design: .rounded),
        codeFont: Font = .system(size: 13, weight: .regular, design: .monospaced),
        sectionTitleFont: Font = .system(size: 15, weight: .semibold, design: .rounded)
    ) {
        self.windowBackground = windowBackground
        self.panelBackground = panelBackground
        self.editorBackground = editorBackground
        self.accentColor = accentColor
        self.textColor = textColor
        self.dividerColor = dividerColor
        self.bodyFont = bodyFont
        self.codeFont = codeFont
        self.sectionTitleFont = sectionTitleFont
    }

    var divider: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(height: 1)
            .opacity(0.7)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
