//
//  FullScreenImageView.swift
//  PunjabAppNew
//
//  Created by pc on 19/11/25.
//
import SwiftUI
import Kingfisher

struct FullScreenImageView: View {
    let imageURLs: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    ZoomableImage(url: imageURLs[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                Spacer()
            }
            
            // Page indicator
            VStack {
                Spacer()
                Text("\(selectedIndex + 1) / \(imageURLs.count)")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(.bottom, 20)
            }
        }
    }
}


