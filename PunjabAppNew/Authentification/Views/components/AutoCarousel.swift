//
//  AutoCarousel.swift
//  PunjabAppNew
//
//  Created by pc on 19/11/25.
//


import SwiftUI
import Kingfisher

import SwiftUI
import Kingfisher

struct AutoCarousel: View {
    let photos: [Photo_multi]
    let autoDelay: Double = 3.0
    
    @State private var currentIndex = 0
    @State private var showFullscreen = false
    @State private var selectedImage: String = ""
    @State private var selectedIndex = 0

    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 10) {
            
            TabView(selection: $currentIndex) {
                ForEach(photos.indices, id: \.self) { i in
                    
                    KFImage(URL(string: photos[i].image ?? ""))
                        .placeholder { ProgressView() }
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .tag(i)
                        .onTapGesture {
                            selectedIndex = i
                            selectedImage = photos[i].image ?? ""
                            showFullscreen = true
                        }
                }
            }
            .tabViewStyle(.page)
            .frame(height: carouselHeight())
            .onReceive(timer) { _ in
                guard !photos.isEmpty else { return }
                withAnimation {
                    currentIndex = (currentIndex + 1) % photos.count
                }
            }
            
//            // --- DOT INDICATORS ---
//            HStack(spacing: 6) {
//                ForEach(0..<photos.count, id: \.self) { index in
//                    Circle()
//                        .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.35))
//                        .frame(width: 8, height: 8)
//                }
//            }
            
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            FullScreenImageView(
                imageURLs: photos.compactMap { $0.image },
                selectedIndex: $selectedIndex
            )
        }
    }
    
    private func carouselHeight() -> CGFloat {
        UIScreen.main.bounds.width * 3/4   // 4:3 ratio
    }
}

