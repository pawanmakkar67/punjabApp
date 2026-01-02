//
//  CreateStoryView.swift
//  PunjabAppNew
//
//  Created by pc on 16/12/2025.
//
//

import SwiftUI
import UIKit // Added for UIViewControllerRepresentable types
import PhotosUI
import AVFoundation
import PencilKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct CreateStoryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FeedViewModel
    
    // Camera Logic
    @StateObject private var cameraService = CameraService()
    
    // UI State
    @State private var showPhotoPicker: Bool = false
    
    // --- TOOLS STATE ---
    @State private var canvasView = PKCanvasView()
    @State private var isDrawing: Bool = false
    @State private var showTextEditor: Bool = false
    @State private var currentText: String = ""
    @State private var texts: [StoryText] = []
    
    // --- FILTERS STATE ---
    @State private var currentFilterIndex: Int = 0
    let filters: [FilterType] = [
        .original, .sepia, .monochrome, .vignette, .instant
    ]
    
    struct StoryText: Identifiable {
        let id = UUID()
        var text: String
        var color: Color = .white
        var offset: CGSize = .zero
        var lastOffset: CGSize = .zero
    }
    
    enum FilterType: String, CaseIterable, Identifiable {
        case original = "Original"
        case sepia = "Sepia"
        case monochrome = "B&W"
        case vignette = "Vintage"
        case instant = "Instant"
        
        var id: String { self.rawValue }
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
                    // --- Captured/Edit Mode ---
                    Image(uiImage: applyFilter(to: image, filter: filters[currentFilterIndex]))
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    // --- Live Camera Mode ---
                    StoryCameraWrapper(cameraService: cameraService)
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
                            // Camera Tools: Flash, Switch, Music
                            Button {
                                cameraService.switchCamera()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            
                            Button {
                                cameraService.toggleFlash()
                            } label: {
                                Image(systemName: cameraService.flashMode == .off ? "bolt.slash.fill" : "bolt.fill")
                                    .font(.title2)
                                    .foregroundStyle(cameraService.flashMode == .off ? .white : .yellow)
                            }
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
                        // Filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(filters.indices, id: \.self) { i in
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: currentFilterIndex == i ? 3 : 1)
                                        .background(Circle().fill(Color.white.opacity(0.2)))
                                        .frame(width: 50, height: 50)
                                        .overlay(Text(filters[i].rawValue.prefix(1)).font(.caption).foregroundStyle(.white))
                                        .onTapGesture {
                                            currentFilterIndex = i
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 60)
                        
                        // Shutter / Capture Area
                        HStack {
                            Button { showPhotoPicker.toggle() } label: {
                                Image(systemName: "photo.on.rectangle.angled").font(.title).foregroundStyle(.white)
                            }
                            Spacer()
                            
                            // SwiftyRecordButton Wrapper
                            SwiftyRecordButtonWrapper(cameraService: cameraService)
                                .frame(width: 80, height: 80)
                            
                            Spacer()
                            Button {} label: { Image(systemName: "face.smiling").font(.title).foregroundStyle(.white) }
                        }
                        .padding(.horizontal, 40).padding(.bottom, 30)
                    }
                }
            } // End Layer 4
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.createStorySelectedImage)
        .onAppear { cameraService.checkPermission() }
    }
    
    // --- HELPERS ---
    
    var hasMedia: Bool {
        cameraService.capturedImage != nil || viewModel.createStorySelectedImage != nil
    }
    
    func getBaseImage() -> UIImage? {
        if let captured = cameraService.capturedImage { return captured }
        if let picked = viewModel.createStorySelectedImage, let uiImg = viewModel.uiImage { return uiImg }
        return nil
    }
    
    func clearMedia() {
        cameraService.retake()
        viewModel.createStorySelectedImage = nil
        viewModel.uiImage = nil
        // Reset tools
        canvasView.drawing = PKDrawing()
        texts.removeAll()
        isDrawing = false
        currentFilterIndex = 0
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
    
    func applyFilter(to inputImage: UIImage, filter: FilterType) -> UIImage {
        // Basic filter logic
        if filter == .original { return inputImage }
        
        let context = CIContext()
        guard let ciImage = CIImage(image: inputImage) else { return inputImage }
        
        var ciFilter: CIFilter?
        
        switch filter {
        case .sepia:
            ciFilter = CIFilter.sepiaTone()
            ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            ciFilter?.setValue(0.8, forKey: kCIInputIntensityKey)
        case .monochrome:
            ciFilter = CIFilter.photoEffectMono()
            ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        case .vignette:
            ciFilter = CIFilter.vignette()
            ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            ciFilter?.setValue(1.0, forKey: kCIInputIntensityKey)
        case .instant:
            ciFilter = CIFilter.photoEffectInstant()
            ciFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        default: break
        }
        
        if let output = ciFilter?.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }
        return inputImage
    }
    
    private func postStory() {
        guard let base = getBaseImage() else { return }
        
        // Render layers logic would go here (merge View + Canvas + Text into one Image).
        // For now, we upload the base image + filter.
        // Merging views is complex/slow, so we will ship the base filtered image
        // and acknowledge drawing is visual only for MVP unless we render it.
        // Let's TRY to render the canvas if possible, but it implies Snapshotting.
        // MVP: Upload filtered image.
        
        let filtered = applyFilter(to: base, filter: filters[currentFilterIndex])
        
        // TODO: Merge Drawing/Text. 
        // We will assume "filtered" is the result for now.
        
        viewModel.storyUiImage = filtered
        
        Task {
            try await viewModel.uploadStory()
            dismiss()
        }
    }
}

// Wrapper for SwiftyCamViewController defined in CameraService.swift
struct StoryCameraWrapper: UIViewControllerRepresentable {
    @ObservedObject var cameraService: CameraService
    
    typealias UIViewControllerType = SwiftyCamViewController

    func makeUIViewController(context: Context) -> SwiftyCamViewController {
        let controller = SwiftyCamViewController()
        controller.cameraDelegate = cameraService
        controller.shouldPrompToAppSettings = true
        controller.maximumVideoDuration = 60.0
        controller.shouldUseDeviceOrientation = true
        controller.allowAutoRotate = false
        controller.audioEnabled = true
        controller.videoGravity = .resizeAspectFill
        controller.tapToFocus = true
        controller.pinchToZoom = true
        
        cameraService.viewController = controller // Bind actions
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SwiftyCamViewController, context: Context) {}
}

struct SwiftyRecordButtonWrapper: UIViewRepresentable {
    @ObservedObject var cameraService: CameraService
    typealias UIViewType = SwiftyRecordButton
    
    func makeUIView(context: Context) -> SwiftyRecordButton {
        let button = SwiftyRecordButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        button.delegate = cameraService
        
        // Make sure it looks enabled initially
        button.buttonEnabled = true
        
        return button
    }
    
    func updateUIView(_ uiView: SwiftyRecordButton, context: Context) {
        if cameraService.isRecording {
            uiView.growButton()
        } else {
            uiView.shrinkButton()
        }
    }
}
