//
//  VisibilityDetector.swift
//  PunjabAppNew
//
//  Created by pc on 19/11/25.
//

import SwiftUI

struct VisibilityDetector: View {
    let index: Int
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { _ in
                    let mid = UIScreen.main.bounds.height / 2
                    let rect = geo.frame(in: .global)
                    
                    if rect.minY < mid && rect.maxY > mid {
                        viewModel.focusedIndex = index
                    }
                }
        }
    }
}
