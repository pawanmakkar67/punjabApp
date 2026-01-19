import UIKit
import SceneKit
import ARKit

class FaceTrackingViewModel: ObservableObject {
    
    // MARK: - Properties
    
    // Data
    @Published var allFilters: [Filter] = []
    @Published var selectedFilterIndex: Int?
    
    // Feature Options (Source of Truth)
    let noseOptions = ["nose01", "nose02", "nose03", "nose04", "nose05", "nose06", "nose07", "nose08"]
    let glassesOptions = ["glasses01", "glasses02", "glasses03"]
    let beardOptions = ["beard01", "beard02", "beard03", "beard04"]
    let features = ["nose", "glasses", "beard"]
    let featureIndices = [[6], [1064, 1097], [152]] // nose tip, left/right eye centers, chin
    
    // Recording State
    @Published var isRecording = false
    @Published var isRecordingLocked = false
    @Published var isFrontCamera = true
    @Published var statusMessage: String?
    @Published var capturedImage: UIImage?
    @Published var capturedVideoURL: URL?
    @Published var debugLog: String = "Debug Initialized" // Debug HUD
    
    // Actions
    var triggerCapture: (() -> Void)?
    
    let videoRecorder = VideoRecorder()
    
    // Zoom State
    var currentZoomFactor: CGFloat = 1.0
    var initialZoomFactor: CGFloat = 1.0
    
    // MARK: - Initialization
    init() {
        setupFilters()
    }
    
    private func setupFilters() {
        // Populate filters
        for nose in noseOptions { allFilters.append(Filter(imageName: nose, type: .nose)) }
        for glasses in glassesOptions { allFilters.append(Filter(imageName: glasses, type: .glasses)) }
        for beard in beardOptions { allFilters.append(Filter(imageName: beard, type: .beard)) }
    }
    
    // MARK: - Filter Selection
    
    func selectFilter(at index: Int) {
        if index == selectedFilterIndex {
            selectedFilterIndex = nil // Deselect
        } else {
            selectedFilterIndex = index
        }
    }
    
    func getSelectedFilter() -> Filter? {
        guard let index = selectedFilterIndex, index < allFilters.count else { return nil }
        return allFilters[index]
    }
    
    // MARK: - Recording Logic
    
    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        videoRecorder.startRecording()
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
             completion(nil)
             return
        }
        
        isRecording = false
        isRecordingLocked = false
        
        videoRecorder.stopRecording(completion: completion)
    }
    
    func lockRecording() {
        isRecordingLocked = true
    }
    
    func unlockRecording() {
        isRecordingLocked = false
    }
    
    func toggleCamera() {
        isFrontCamera.toggle()
    }
    
    // MARK: - Frame Processing
    
    func processFrame(buffer: CVPixelBuffer, time: TimeInterval) {
        if isRecording {
            videoRecorder.writeFrame(for: buffer, time: time)
        }
    }
    
    func processAudio(buffer: CMSampleBuffer) {
        if isRecording {
            videoRecorder.writeAudio(sampleBuffer: buffer)
        }
    }
}
