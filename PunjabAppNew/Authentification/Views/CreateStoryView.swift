//
//  CreateStoryView.swift
//  PunjabAppNew
//
//  Created by pc on 16/12/2025.
//
//

import SwiftUI
import UIKit
import PhotosUI
import AVFoundation
import AVKit
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct CreateStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FeedViewModel
    
    // AR ViewModel
    @StateObject private var faceTrackingViewModel = FaceTrackingViewModel()
    
    // Legacy Camera (Keep if needed for fallback, but main focus is AR)
    @StateObject private var cameraService = CameraService() 
    
    // UI State
    @State private var showPhotoPicker: Bool = false
    
    // --- TOOLS STATE ---
    @State private var canvasView = PKCanvasView()
    @State private var isDrawing: Bool = false
    @State private var showTextEditor: Bool = false
    @State private var currentText: String = ""
    @State private var texts: [StoryText] = []
    
    struct StoryText: Identifiable {
        let id = UUID()
        var text: String
        var color: Color = .white
        var offset: CGSize = .zero
        var lastOffset: CGSize = .zero
    }
    
    // Tools Model
    struct Tool: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        let action: ToolAction
    }
    
    enum ToolAction {
        case text, draw, stickers, none
    }
    
    var tools: [Tool] {
        [
            Tool(icon: "textformat", name: "Text", action: .text),
            Tool(icon: isDrawing ? "pencil.slash" : "pencil", name: "Draw", action: .draw),
            Tool(icon: "square.stack.3d.down.right", name: "Stickers", action: .none),
            Tool(icon: "scissors", name: "Cut", action: .none),
            Tool(icon: "music.note", name: "Music", action: .none),
            Tool(icon: "link", name: "Link", action: .none),
            Tool(icon: "crop", name: "Crop", action: .none),
            Tool(icon: "timer", name: "Timer", action: .none)
        ]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // MARK: - Layer 1: Media (Camera or Image)
            ZStack {
                if let image = getBaseImage() {
                    // --- Captured/Edit Mode (Photo) ---
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                } else if let videoURL = faceTrackingViewModel.capturedVideoURL {
                    // --- Captured/Edit Mode (Video) ---
                    StoryVideoPlayer(url: videoURL)
                        .ignoresSafeArea()
                } else {
                    // --- Live Camera Mode (AR) ---
                    ARStoryCameraView(viewModel: faceTrackingViewModel)
                        .ignoresSafeArea()
                }
            }
            .onTapGesture {
                // Dimiss keyboard/drawing if active
                if showTextEditor { showTextEditor = false }
            }
            
            // MARK: - Layer 2: Drawing Canvas
            // Only visible if we have an image (Edit Mode)
            if hasMedia {
                DrawingCanvasView(canvasView: $canvasView, isDrawing: $isDrawing, color: .red)
                    .ignoresSafeArea()
                    .allowsHitTesting(isDrawing) // Pass touches only when drawing
            }
            
            // MARK: - Layer 3: Text Overlays
            if hasMedia {
                ForEach($texts) { $storyText in
                    Text(storyText.text)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(storyText.color)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .offset(storyText.offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    storyText.offset = CGSize(
                                        width: storyText.lastOffset.width + value.translation.width,
                                        height: storyText.lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    storyText.lastOffset = storyText.offset
                                }
                        )
                }
            }

            // MARK: - Layer 4: UI Overlays (Chrome)
            VStack {
                // --- TOP BAR ---
                HStack(alignment: .top) {
                    Button {
                        if hasMedia {
                            // Retake logic
                            clearMedia()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Top Center
                    if hasMedia {
                        Label("Add a Sound", systemImage: "music.note")
                            .font(.caption).fontWeight(.semibold)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.ultraThinMaterial).clipShape(Capsule())
                    } else {
                         Image(systemName: "person.circle.fill")
                             .font(.largeTitle).foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // --- TOOLS ---
                    VStack(spacing: 20) {
                        if hasMedia {
                            // Edit Tools
                            ForEach(tools) { tool in
                                Button {
                                    handleTool(tool.action)
                                } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName: tool.icon)
                                            .font(.title2)
                                            .foregroundStyle(tool.action == .draw && isDrawing ? .red : .white)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                        } else {
                            // Camera Tools: Switch (Flash not available in ARFaceTracking usually)
//                            Button {
//                                // Switch Camera Logic (ARKit usually defaults to front)
//                            } label: {
//                                Image(systemName: "arrow.triangle.2.circlepath.camera")
//                                    .font(.title2)
//                                    .foregroundStyle(.white)
//                            }
                        }
                    }
                    .padding(.top)
                    .padding(.trailing)
                }
                
                Spacer()
                
                // --- BOTTOM BAR ---
                if hasMedia {
                    if showTextEditor {
                        // Text Input Mode
                        HStack {
                            TextField("Type something...", text: $currentText)
                                .font(.title)
                                .foregroundStyle(.white)
                                .submitLabel(.done)
                                .onSubmit {
                                    addText()
                                }
                            Button("Done") {
                                addText()
                            }
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                    } else {
                        // Edit Mode Bottom
                        HStack {
                            Button {} label: {
                                Image(systemName: "arrow.down.to.line")
                                    .font(.title3).fontWeight(.bold).foregroundStyle(.white)
                                    .padding(10).background(Color.white.opacity(0.2)).clipShape(Circle())
                            }
                            
                            Button { postStory() } label: {
                                VStack(spacing: 2) {
                                    Image(systemName: "person.crop.circle.badge.plus").font(.title2)
                                    Text("Story").font(.caption2).fontWeight(.bold)
                                }
                                .foregroundStyle(.white).padding(.leading, 10)
                            }
                            
                            Spacer()
                            
                            Button { postStory() } label: {
                                HStack {
                                    Text("Send To").font(.headline).fontWeight(.bold)
                                    Image(systemName: "arrowtriangle.right.fill").font(.caption)
                                }
                                .foregroundStyle(.black).padding(.horizontal, 20).padding(.vertical, 12)
                                .background(Color.yellow).clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal).padding(.bottom, 20)
                    }
                } else {
                    // --- CAMERA MODE BOTTOM ---
                    VStack(spacing: 20) {
                        // AR Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(faceTrackingViewModel.allFilters.indices, id: \.self) { i in
                                    let filter = faceTrackingViewModel.allFilters[i]
                                    let isSelected = faceTrackingViewModel.selectedFilterIndex == i
                                    
                                    Image(filter.imageName) // Ensure these images exist in Assets
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: isSelected ? 3 : 0))
                                        .onTapGesture {
                                            faceTrackingViewModel.selectFilter(at: i)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 70)
                        
                        // Shutter / Capture Area
                        HStack {
                            Button { showPhotoPicker.toggle() } label: {
                                Image(systemName: "photo.on.rectangle.angled").font(.title).foregroundStyle(.white)
                            }
                            Spacer()
                            
                            // Shutter Button
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                Circle()
                                    .fill(faceTrackingViewModel.isRecording ? Color.red : Color.white)
                                    .frame(width: faceTrackingViewModel.isRecording ? 40 : 70, height: faceTrackingViewModel.isRecording ? 40 : 70)
                                    .animation(.easeInOut(duration: 0.2), value: faceTrackingViewModel.isRecording)
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                                    if !faceTrackingViewModel.isRecording {
                                        faceTrackingViewModel.startRecording()
                                    }
                                }
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { _ in
                                        if faceTrackingViewModel.isRecording {
                                            faceTrackingViewModel.stopRecording { url in
                                                if let url = url {
                                                    DispatchQueue.main.async {
                                                        faceTrackingViewModel.capturedVideoURL = url
                                                    }
                                                }
                                            }
                                        } else {
                                            // Tap behavior (captured before LongPress triggered)
                                            faceTrackingViewModel.triggerCapture?()
                                        }
                                    }
                            )
                            
                            Spacer()
                            Button {} label: { Image(systemName: "face.smiling").font(.title).foregroundStyle(.white) }
                        }
                        .padding(.horizontal, 40).padding(.bottom, 30)
                    }
                }
            } // End Layer 4
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.createStorySelectedImage)
    }
    
    // --- HELPERS ---
    
    var hasMedia: Bool {
        faceTrackingViewModel.capturedImage != nil ||
        faceTrackingViewModel.capturedVideoURL != nil ||
        viewModel.createStorySelectedImage != nil
    }
    
    func getBaseImage() -> UIImage? {
        if let captured = faceTrackingViewModel.capturedImage { return captured }
        if let picked = viewModel.createStorySelectedImage, let uiImg = viewModel.uiImage { return uiImg }
        return nil
    }
    
    func clearMedia() {
        faceTrackingViewModel.capturedImage = nil
        faceTrackingViewModel.capturedVideoURL = nil
        viewModel.createStorySelectedImage = nil
        viewModel.uiImage = nil
        // Reset tools
        canvasView.drawing = PKDrawing()
        texts.removeAll()
        isDrawing = false
    }
    
    func handleTool(_ action: ToolAction) {
        switch action {
        case .text:
            showTextEditor = true
            isDrawing = false
        case .draw:
            isDrawing.toggle()
        default: break
        }
    }
    
    func addText() {
        guard !currentText.isEmpty else { 
            showTextEditor = false
            return 
        }
        let newText = StoryText(text: currentText)
        texts.append(newText)
        currentText = ""
        showTextEditor = false
    }
    
    private func postStory() {
        // Handle Video Upload
        if let videoURL = faceTrackingViewModel.capturedVideoURL {
             Task {
                 print("Video Upload from Story: \(videoURL)")
                 // TODO: Integrate actual video upload
                 dismiss()
             }
             return
        }
        
        guard let base = getBaseImage() else { return }
        viewModel.storyUiImage = base
        
        Task {
            try await viewModel.uploadStory()
            dismiss()
        }
    }
}

struct StoryVideoPlayer: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        player.play()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

