//
//  Font+Ext.swift
//  batagor
//
//  Created by Gede Pramananda Kusuma Wisesa on 05/11/25.
//

import SwiftUI

extension Font {
    private static func spaceGrotesk(_ weight: SpaceGroteskWeight, size: CGFloat) -> Font {
        return .custom(weight.fontName, size: size)
    }
    
    // Headings
    static let heading1 = spaceGrotesk(.bold, size: 34)
    static let heading2 = spaceGrotesk(.bold, size: 28)
    static let heading3 = spaceGrotesk(.semiBold, size: 22)
    static let heading4 = spaceGrotesk(.semiBold, size: 20)
    
    // Body Text
    static let bodyLarge = spaceGrotesk(.regular, size: 17)
    static let body = spaceGrotesk(.regular, size: 15)
    static let bodySmall = spaceGrotesk(.regular, size: 13)
    
    // Special Purpose
    static let caption = spaceGrotesk(.medium, size: 12)
    static let button = spaceGrotesk(.semiBold, size: 16)
    static let label = spaceGrotesk(.medium, size: 14)
    
    // Standard SwiftUI
    static let largeTitle = spaceGrotesk(.bold, size: 34)
    static let title = spaceGrotesk(.bold, size: 28)
    static let title2 = spaceGrotesk(.semiBold, size: 22)
    static let title3 = spaceGrotesk(.semiBold, size: 20)
    static let headline = spaceGrotesk(.semiBold, size: 17)
    static let subheadline = spaceGrotesk(.medium, size: 15)
    static let callout = spaceGrotesk(.regular, size: 16)
    static let footnote = spaceGrotesk(.regular, size: 13)
    static let caption2 = spaceGrotesk(.regular, size: 11)
    
    static func spaceGroteskRegular(size: CGFloat) -> Font {
        return spaceGrotesk(.regular, size: size)
    }
    
    static func spaceGroteskMedium(size: CGFloat) -> Font {
        return spaceGrotesk(.medium, size: size)
    }
    
    static func spaceGroteskSemiBold(size: CGFloat) -> Font {
        return spaceGrotesk(.semiBold, size: size)
    }
    
    static func spaceGroteskBold(size: CGFloat) -> Font {
        return spaceGrotesk(.bold, size: size)
    }
    
    static func spaceGroteskLight(size: CGFloat) -> Font {
        return spaceGrotesk(.light, size: size)
    }
}

private enum SpaceGroteskWeight {
    case light
    case regular
    case medium
    case semiBold
    case bold
    
    var fontName: String {
        switch self {
        case .light: return "SpaceGrotesk-Light"
        case .regular: return "SpaceGrotesk-Regular"
        case .medium: return "SpaceGrotesk-Medium"
        case .semiBold: return "SpaceGrotesk-SemiBold"
        case .bold: return "SpaceGrotesk-Bold"
        }
    }
}
