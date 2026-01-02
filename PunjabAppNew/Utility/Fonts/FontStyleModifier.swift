//
//  FontStyleModifier.swift
//  PunjabAppNew
//
//  Created by pc on 29/10/25.
//


//
//  FontModifier.swift
//  YourApp
//
//  Created by Pawanpreet Singh on 29/10/25.
//

import SwiftUI

struct FontStyleModifier: ViewModifier {
    let name: FontName
    let size: StandardSize

    func body(content: Content) -> some View {
        content.font(.lato(name, size: size))
    }
}

extension View {
    func fontStyle(_ name: FontName, size: StandardSize) -> some View {
        self.modifier(FontStyleModifier(name: name, size: size))
    }
}
