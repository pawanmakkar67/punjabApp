//
//  FontName.swift
//  PunjabAppNew
//
//  Created by pc on 29/10/25.
//


//
//  FontConstant.swift
//  YourApp
//
//  Created by Pawanpreet Singh on 29/10/25.
//

import SwiftUI

/// Custom font names (make sure they are in your project and Info.plist)
enum FontName: String {
    case regular   = "Lato-Regular"
    case light     = "Lato-Light"
    case bold      = "Lato-Heavy"
    case semiBold  = "Lato-Bold"
}

/// Font size constants
enum StandardSize: CGFloat {
    case h1 = 8
    case h2 = 9
    case h3 = 10
    case h4 = 11
    case h5 = 12
    case h6 = 13
    case h7 = 14
    case h8 = 15
    case h9 = 16
    case h10 = 17
    case h11 = 18
    case h12 = 20
    case h13 = 22
    case h14 = 24
    case h15 = 26
    case h16 = 28
    case h17 = 30
    case h18 = 32
}


extension Font {
    
    /// Create font using your Lato family
    static func lato(_ name: FontName, size: StandardSize) -> Font {
        return .custom(name.rawValue, size: size.rawValue)
    }
    
    /// Convenience helpers
    static func latoRegular(_ size: StandardSize) -> Font {
        .lato(.regular, size: size)
    }
    
    static func latoBold(_ size: StandardSize) -> Font {
        .lato(.bold, size: size)
    }
    
    static func latoSemiBold(_ size: StandardSize) -> Font {
        .lato(.semiBold, size: size)
    }
    
    static func latoLight(_ size: StandardSize) -> Font {
        .lato(.light, size: size)
    }
}
