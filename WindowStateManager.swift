import SwiftUI
import AppKit

class WindowStateManager {
    static func save(window: NSWindow) {
        let frame = NSStringFromRect(window.frame)
        UserDefaults.standard.set(frame, forKey: "WeWillDoItLive.WindowFrame")
    }

    static func restore(for window: NSWindow) {
        if let frameStr = UserDefaults.standard.string(forKey: "WeWillDoItLive.WindowFrame") {
            let frame = NSRectFromString(frameStr)
            window.setFrame(frame, display: true)
        }
    }
}
