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
    @ObservedObject var viewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    
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
    @State private var editingTextId: UUID? = nil
    @State private var isDraggingItem: Bool = false
    @State private var trashThreshold: CGFloat = 0
    @State private var isEraser: Bool = false
    
    // --- STICKERS STATE ---
    @State private var stickers: [StorySticker] = []
    @State private var showStickerPicker: Bool = false
    
    struct StorySticker: Identifiable {
        let id = UUID()
        let content: String // Emoji
        var offset: CGSize = .zero
        var lastOffset: CGSize = .zero
        var scale: CGFloat = 1.0
        var lastScale: CGFloat = 1.0
    }
    
    // --- CROP STATE ---
    @State private var showCropView: Bool = false
    @State private var croppingImage: UIImage?
    
    // --- MUSIC STATE ---
    @State private var showMusicPicker: Bool = false
    @State private var selectedMusic: String? = nil
    
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
        case text, draw, eraser, stickers, crop, music, none
    }
    
    var tools: [Tool] {
        [
            Tool(icon: "textformat", name: "Text", action: .text),
            Tool(icon: isDrawing ? "pencil.slash" : "pencil", name: "Draw", action: .draw),
            Tool(icon: "eraser", name: "Eraser", action: .eraser),
            Tool(icon: "square.stack.3d.down.right", name: "Stickers", action: .stickers),
            Tool(icon: "scissors", name: "Cut", action: .none),
            Tool(icon: "music.note", name: "Music", action: .music),
            Tool(icon: "link", name: "Link", action: .none),
            Tool(icon: "crop", name: "Crop", action: .crop),
//            Tool(icon: "timer", name: "Timer", action: .none)
        ]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Layer 1: Media
            mediaLayer
                .onTapGesture {
                    if showTextEditor { showTextEditor = false }
                }
            
            // Layer 2: Drawing
            if hasMedia {
                DrawingCanvasView(canvasView: $canvasView, isDrawing: $isDrawing, color: .red, isEraser: isEraser)
                    .ignoresSafeArea()
                    .allowsHitTesting(isDrawing)
            }
            
            // Layer 3: Text
            if hasMedia {
                ForEach($texts) { $storyText in
                    Text(storyText.text)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(storyText.color)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .offset(storyText.offset)
                        .onTapGesture {
                            currentText = storyText.text
                            editingTextId = storyText.id
                            showTextEditor = true
                        }
                        .gesture(
                            DragGesture(coordinateSpace: .global)
                                .onChanged { value in
                                    isDraggingItem = true
                                    storyText.offset = CGSize(
                                        width: storyText.lastOffset.width + value.translation.width,
                                        height: storyText.lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { value in
                                    isDraggingItem = false
                                    storyText.lastOffset = storyText.offset
                                    // Delete Check
                                    if value.location.y > UIScreen.main.bounds.height - 150 {
                                        if let index = texts.firstIndex(where: { $0.id == storyText.id }) {
                                            texts.remove(at: index)
                                        }
                                    }
                                }
                        )
                }
            }
            
            // Layer 3b: Stickers
            if hasMedia {
                stickersLayer
            }

            // Layer 4: UI Chrome
            VStack {
                topOverlay
                Spacer()
                bottomOverlay
            }
            
            // Layer 5: Trash Overlay
            trashBinLayer
            
            // Layer 6: Status Toast
            if let message = faceTrackingViewModel.statusMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.bottom, 100)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: faceTrackingViewModel.statusMessage)
                .onAppear {
                    // Auto-dismiss after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        faceTrackingViewModel.statusMessage = nil
                    }
                }
            }
            
            Text(faceTrackingViewModel.debugLog)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.yellow)
                .background(Color.black.opacity(0.5))
                .padding(.top, 100)
                .allowsHitTesting(false)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.createStorySelectedImage, matching: .any(of: [.images, .videos]))
        .sheet(isPresented: $showStickerPicker) {
            StickerPickerView { emoji in
                stickers.append(StorySticker(content: emoji))
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showMusicPicker) {
            MusicPickerView { song in
                selectedMusic = song
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showCropView) {
            ImageCropperView(image: $croppingImage) { cropped in
                 if faceTrackingViewModel.capturedImage != nil {
                     faceTrackingViewModel.capturedImage = cropped
                 } else {
                     viewModel.uiImage = cropped
                 }
            }
        }
    }
    
    // --- SUBVIEWS ---
    
    @ViewBuilder
    var mediaLayer: some View {
        ZStack {
            if let image = getBaseImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            } else if let videoURL = faceTrackingViewModel.capturedVideoURL {
                StoryVideoPlayer(url: videoURL)
                    .ignoresSafeArea()
            } else if let galleryVideo = viewModel.storyVideoURL {
                StoryVideoPlayer(url: galleryVideo)
                    .ignoresSafeArea()
            } else {
                ARStoryCameraView(viewModel: faceTrackingViewModel)
                    .ignoresSafeArea()
            }
        }
    }
    
    @ViewBuilder
    var stickersLayer: some View {
         ForEach($stickers) { $sticker in
             Text(sticker.content)
                 .font(.system(size: 80))
                 .scaleEffect(sticker.scale)
                 .offset(sticker.offset)
                 .gesture(
                     SimultaneousGesture(
                         DragGesture(coordinateSpace: .global)
                             .onChanged { value in
                                 isDraggingItem = true
                                 sticker.offset = CGSize(
                                     width: sticker.lastOffset.width + value.translation.width,
                                     height: sticker.lastOffset.height + value.translation.height
                                 )
                             }
                             .onEnded { value in
                                 isDraggingItem = false
                                 sticker.lastOffset = sticker.offset
                                 // Delete Check
                                 if value.location.y > UIScreen.main.bounds.height - 150 {
                                     if let index = stickers.firstIndex(where: { $0.id == sticker.id }) {
                                         stickers.remove(at: index)
                                     }
                                 }
                             },
                         MagnificationGesture()
                             .onChanged { value in
                                 sticker.scale = sticker.lastScale * value
                             }
                             .onEnded { _ in
                                 sticker.lastScale = sticker.scale
                             }
                     )
                 )
         }
    }
    
    @ViewBuilder
    var topOverlay: some View {
        HStack(alignment: .top) {
            Button {
                if hasMedia {
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
            
            if isDrawing {
                 HStack(spacing: 20) {
                     Button {
                         // Undo/Clear
                         canvasView.drawing = PKDrawing()
                     } label: {
                         Image(systemName: "trash")
                             .font(.title2)
                             .foregroundStyle(.white)
                             .padding(8)
                             .background(.ultraThinMaterial)
                             .clipShape(Circle())
                     }
                     
                     Button {
                        // Toggle back to normal
                        isDrawing = false
                     } label: {
                         Text("Done")
                             .fontWeight(.bold)
                             .foregroundStyle(.white)
                             .padding(.horizontal, 12)
                             .padding(.vertical, 8)
                             .background(Color.yellow)
                             .clipShape(Capsule())
                     }
                 }
            } else if hasMedia {
                 Button {
                     showMusicPicker = true
                 } label: {
                     HStack {
                         Image(systemName: "music.note")
                         Text(selectedMusic ?? "Add a Sound")
                     }
                     .font(.caption).fontWeight(.semibold)
                     .padding(.horizontal, 12).padding(.vertical, 8)
                     .background(.ultraThinMaterial).clipShape(Capsule())
                     .foregroundStyle(.white)
                 }
            } else {
                 Image(systemName: "person.circle.fill")
                     .font(.largeTitle).foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            if !hasMedia && !isDrawing {
                Button {
                    faceTrackingViewModel.toggleCamera()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(.trailing, 8)
            }
            
            if !isDrawing {
                VStack(spacing: 20) {
                    if hasMedia {
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
                    }
                }
                .padding(.top)
                .padding(.trailing)
            }
        }
        .padding(.top, hasMedia ? 60 : 0)
    }

    @ViewBuilder
    var bottomOverlay: some View {
        if hasMedia {
            if showTextEditor {
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
            // Camera Mode Bottom
            // (Keeping the original camera/filter UI logic here would be good, or further extract)
            cameraBottomControls
        }
    }
    
    @ViewBuilder
    var cameraBottomControls: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(faceTrackingViewModel.allFilters.indices, id: \.self) { i in
                        let filter = faceTrackingViewModel.allFilters[i]
                        let isSelected = faceTrackingViewModel.selectedFilterIndex == i
                        
                        Image(filter.imageName)
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
            
            HStack {
                Button { showPhotoPicker.toggle() } label: {
                    Image(systemName: "photo.on.rectangle.angled").font(.title).foregroundStyle(.white)
                }
                Spacer()
                
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

    
    // --- HELPERS ---
    
    var hasMedia: Bool {
        faceTrackingViewModel.capturedImage != nil ||
        faceTrackingViewModel.capturedVideoURL != nil ||
        viewModel.createStorySelectedImage != nil ||
        viewModel.storyUiImage != nil ||
        viewModel.storyVideoURL != nil
    }
    
    func getBaseImage() -> UIImage? {
        if let captured = faceTrackingViewModel.capturedImage { return captured }
        // Use storyUiImage, NOT uiImage (which is for posts)
        if let picked = viewModel.createStorySelectedImage, let storyImg = viewModel.storyUiImage { return storyImg }
        return nil
    }
    
    func clearMedia() {
        faceTrackingViewModel.capturedImage = nil
        faceTrackingViewModel.capturedVideoURL = nil
        viewModel.createStorySelectedImage = nil
        viewModel.storyUiImage = nil
        viewModel.storyVideoURL = nil
        viewModel.uiImage = nil // Consider if we really want to clear post image too?
        // Reset tools
        canvasView.drawing = PKDrawing()
        texts.removeAll()
        stickers.removeAll()
        selectedMusic = nil
        isDrawing = false
    }
    
    func handleTool(_ action: ToolAction) {
        switch action {
        case .text:
            showTextEditor = true
            isDrawing = false
        case .draw:
            isDrawing = true
            isEraser = false
        case .eraser:
            isDrawing = true
            isEraser = true
        case .stickers:
            showStickerPicker = true
            isDrawing = false
        case .music:
             showMusicPicker = true
        case .crop:
             if let base = getBaseImage() {
                 croppingImage = base
                 showCropView = true
                 isDrawing = false
             }
        default: break
        }
    }
    
    func addText() {
        guard !currentText.isEmpty else { 
            showTextEditor = false
            editingTextId = nil
            return 
        }
        
        if let id = editingTextId, let index = texts.firstIndex(where: { $0.id == id }) {
            // Update existing
            texts[index].text = currentText
            // Reset offset if needed or keep it? Keeping it feels natural.
        } else {
            // New text
            let newText = StoryText(text: currentText)
            texts.append(newText)
        }
        
        currentText = ""
        editingTextId = nil
        showTextEditor = false
    }
    
     @ViewBuilder
    var trashBinLayer: some View {
        if isDraggingItem {
            VStack {
                Spacer()
                Image(systemName: "trash.fill")
                     .font(.system(size: 30))
                     .foregroundStyle(.white)
                     .padding(20)
                     .background(Circle().fill(.red))
                     .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.3))
            .animation(.easeInOut, value: isDraggingItem)
        }
    }
    
    private func postStory() {
        // Handle Video Upload (Captured or Gallery)
        if let videoURL = faceTrackingViewModel.capturedVideoURL ?? viewModel.storyVideoURL {
             Task {
                 print("Video Upload from Story: \(videoURL)")
                 do {
                     let videoData = try Data(contentsOf: videoURL)
                     try await viewModel.uploadStory(fileType: "video", fileData: videoData)
                     dismiss()
                 } catch {
                     print("Error uploading video: \(error)")
                 }
             }
             return
        }
        
        // Handle Image Upload
        guard let base = getBaseImage() else { return }
        viewModel.storyUiImage = base
        
        guard let imageData = base.jpegData(compressionQuality: 0.5) else { return }
        
        Task {
            do {
                try await viewModel.uploadStory(fileType: "image", fileData: imageData)
                dismiss()
            } catch {
                 print("Error uploading image: \(error)")
            }
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

