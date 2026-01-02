//
//  ZoomableImage.swift
//  PunjabAppNew
//
//  Created by pc on 19/11/25.
//
import SwiftUI
import Kingfisher

struct ZoomableImage: View {
    let url: String
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        KFImage(URL(string: url))
            .resizable()
            .scaledToFit()
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .scaleEffect(scale)
            .background(Color.black)
            .animation(.easeInOut, value: scale)
    }
}
