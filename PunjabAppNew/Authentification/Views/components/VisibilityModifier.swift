//
//  VisibilityModifier.swift
//  PunjabAppNew
//
//  Created by pc on 19/11/25.
//

import SwiftUI

struct VisibilityModifier: ViewModifier {
    let onVisible: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _ in
                            let screenHeight = UIScreen.main.bounds.height
                            
                            // If part of row is on-screen
                            if geo.frame(in: .global).maxY > 0 &&
                               geo.frame(in: .global).minY < screenHeight {
                                onVisible()
                            }
                        }
                }
            )
    }
}

extension View {
    func onVisible(_ action: @escaping () -> Void) -> some View {
        modifier(VisibilityModifier(onVisible: action))
    }
}
