//
//  Color+Ext.swift
//  batagor
//
//  Created by Tude Maha on 21/10/2025.
//

import SwiftUI

extension Color {
    // MARK: - Helper Methods
    static func rgb(red: Double, green: Double, blue: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255)
    }
    
    static func rgba(red: Double, green: Double, blue: Double, alpha: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Light Colors
    static let lightBase = Color(hex: "#faf4e6")
    static let light10 = Color(hex: "#fefdfa")
    static let light20 = Color(hex: "#fdfbf7")
    static let light30 = Color(hex: "#fcf9f2")
    static let light40 = Color(hex: "#fcf8ee")
    static let light50 = Color(hex: "#fbf6ea")
    static let light60 = Color(hex: "#d0cbc0")
    static let light70 = Color(hex: "#a7a399")
    static let light80 = Color(hex: "#7d7a73")
    static let light90 = Color(hex: "#53514d")
    
    // MARK: - Dark Colors
    static let darkBase = Color(hex: "#1c1c1c")
    static let dark10 = Color(hex: "#d2d2d2")
    static let dark20 = Color(hex: "#b3b3b3")
    static let dark30 = Color(hex: "#8d8d8d")
    static let dark40 = Color(hex: "#686868")
    static let dark50 = Color(hex: "#424242")
    static let dark70 = Color(hex: "#131313")
    static let dark100 = Color(hex: "#060606")
    
    // MARK: - Accent Colors
    static let accentBase = Color(hex: "#d5ffe0")
    
    // MARK: - Yellow Colors
    static let yellowBase = Color(hex: "#ffda85")
    static let yellow20 = Color(hex: "#fff3d6")
    static let yellow30 = Color(hex: "#ffecc2")
    static let yellow50 = Color(hex: "#ffe099")
    static let yellow60 = Color(hex: "#d4a944")
    static let yellow70 = Color(hex: "#aa7d14")
    
    // MARK: - Blue Colors
    static let blueBase = Color(hex: "#a4c1fa")
    static let blue10 = Color(hex: "#edf3fe")
    static let blue20 = Color(hex: "#e1eafd")
    static let blue40 = Color(hex: "#c2d6fc")
    static let blue70 = Color(hex: "#6d81a7")
    static let blue70Hue = Color(hex: "#4c6aa6")
    static let blue90Hue = Color(hex: "#1e3053")
    
    // MARK: - Darker Blue Colors
    static let darkerBlueBase = Color(hex: "#5a90fa")
    static let darkerBlue70 = Color(hex: "#3c5fa6")
    static let darkerBlue90 = Color(hex: "#263653")
    static let darkerBlue70Hue = Color(hex: "#1b49a6")
    static let darkerBlue90Hue = Color(hex: "#0d2553")
    // MARK: - Destroy Colors
    static let redBase = Color(hex: "#de6c62")
    
    // MARK: - Legacy Colors (for backward compatibility)
    static let batagorLight = lightBase
    static let batagorDark = darkBase
    static let batagorPrimary = blueBase
    static let batagorAccent = accentBase
    static let batagorSecondary = yellowBase
    static let batagorDestroy = redBase
}
