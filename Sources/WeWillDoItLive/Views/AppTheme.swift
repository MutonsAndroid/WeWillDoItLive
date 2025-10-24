import SwiftUI

struct AppTheme {
    // Base Layers
    static let background = Color(hex: "#0D0A13")
    static let panel = Color(hex: "#151020")
    static let panelBackground = Color(hex: "#151020")
    static let chatBubbleAI = Color(hex: "#1E182A")

    // Accents
    static let accentPrimary = Color(hex: "#8DFBA3")
    static let accentCoolBlue = Color(hex: "#4C91D0")
    static let accentTeal = Color(hex: "#23A9B4")

    // Text
    static let textPrimary = Color(hex: "#F4FFE0")
    static let textSecondary = Color(hex: "#A6A3B9")
    static let textDisabled = Color(hex: "#6A6880")

    // Utility
    static let border = Color(hex: "#332A4D")
    static let error = Color(hex: "#FF5470")
    static let warning = Color(hex: "#F5A54A")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
