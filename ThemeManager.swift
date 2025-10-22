import SwiftUI

final class ThemeManager: ObservableObject {
    struct TypographyOptions {
        var fontSize: CGFloat
        var useMonospace: Bool
    }

    @Published var currentColorScheme: ColorScheme = .dark
    @Published var primaryAccentColor: Color = Color(red: 130 / 255, green: 170 / 255, blue: 1.0)
    @Published var typography: TypographyOptions = .init(fontSize: 14, useMonospace: true)

    func toggleColorScheme() {
        currentColorScheme = currentColorScheme == .dark ? .light : .dark
    }
}
