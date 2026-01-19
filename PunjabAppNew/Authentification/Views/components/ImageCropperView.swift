
import SwiftUI
import UIKit

struct ImageCropperView: View {
    @Binding var image: UIImage?
    var onCrop: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    
    @State private var viewSize: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // EDITOR AREA (Layer 0)
            GeometryReader { geo in
                ZStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { val in
                                        scale = lastScale * val
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { val in
                                        offset = CGSize(
                                            width: lastOffset.width + val.translation.width,
                                            height: lastOffset.height + val.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                    } else {
                        Text("No Image to Crop")
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .overlay(
                    Rectangle()
                        .stroke(Color.white, lineWidth: 0) // Remove border for full screen preview
                )
                .onAppear {
                    viewSize = geo.size
                }
                .onChange(of: geo.size) { newSize in
                    viewSize = newSize
                }
            }
            .ignoresSafeArea()
            
            // OVERLAY CONTROLS (Layer 1)
            VStack {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                        .padding(10)
                        .contentShape(Rectangle())
                    Spacer()
                    Text("Crop Image")
                        .foregroundStyle(.white)
                        .font(.headline)
                    Spacer()
                    Button("Done") {
                        cropImage()
                    }
                    .foregroundStyle(.yellow)
                    .fontWeight(.bold)
                    .padding(10)
                    .contentShape(Rectangle())
                }
                .padding()
                .background(Color.black.opacity(0.8)) // Semi-transparent background
                
                Spacer()
                
                Text("Pinch to zoom, Drag to move")
                    .foregroundStyle(.gray)
                    .font(.caption)
                    .padding(.bottom, 30) // Extra padding for safety
            }
            .zIndex(1) // Ensure controls are on top
        }
    }
    
    @MainActor
    func cropImage() {
        let renderer = ImageRenderer(content:
            ZStack {
                if let image = image {
                     Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                }
            }
            .frame(width: viewSize.width, height: viewSize.height)
        )
        
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(viewSize)
        
        if let uiImage = renderer.uiImage {
            onCrop(uiImage)
        } else {
             print("Renderer failed to produce image")
             // Fallback to original if render fails
             if let img = image { onCrop(img) }
        }
        dismiss()
    }
}
