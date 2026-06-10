import SwiftUI

// MARK: - Design tokens for the Art of Fauna-inspired Juneteenth aesthetic

enum Theme {

    // MARK: Colours

    /// Aged parchment — primary background
    static let parchment    = Color(red: 0.96, green: 0.92, blue: 0.84)

    /// Deep sepia — primary text and borders
    static let inkBrown     = Color(red: 0.25, green: 0.15, blue: 0.08)

    /// Warm mid-tone for secondary borders and dividers
    static let tileBorder   = Color(red: 0.45, green: 0.30, blue: 0.18)

    /// Muted gold accent — highlights, solved indicator
    static let goldAccent   = Color(red: 0.72, green: 0.53, blue: 0.18)

    /// Deep red from the Juneteenth flag
    static let juneteenthRed = Color(red: 0.65, green: 0.09, blue: 0.09)

    // MARK: Geometry

    static let tileCornerRadius: CGFloat = 6
    static let tileGap: CGFloat          = 3

    // MARK: Fonts

    static func serif(_ style: Font.TextStyle) -> Font {
        .system(style, design: .serif)
    }

    static func serifBold(_ style: Font.TextStyle) -> Font {
        .system(style, design: .serif).bold()
    }
}
