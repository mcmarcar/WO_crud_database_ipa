import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            (r, g, b) = (Double((int >> 16) & 0xFF) / 255,
                         Double((int >> 8)  & 0xFF) / 255,
                         Double( int        & 0xFF) / 255)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(red: r, green: g, blue: b)
    }
}

// App brand colours (matching the Android app)
extension Color {
    static let appPrimary        = Color(hex: "1565C0")
    static let appPrimaryDark    = Color(hex: "0D47A1")
    static let sortHighlight     = Color(hex: "7B1FA2").opacity(0.15)
    static let sortHighlightText = Color(hex: "7B1FA2")
}
