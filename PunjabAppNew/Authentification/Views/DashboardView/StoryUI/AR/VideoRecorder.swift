import UIKit
import AVFoundation
import ARKit
import Photos

class VideoRecorder: NSObject {
    
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var isRecording = false
    private var startTime: CMTime = .zero
    private var outputUrl: URL?
    
    // Video Settings
    private let frameRate: Int32 = 30
    
    override init() {
        super.init()
    }
    
    // MARK: - API
    
    // Serial queue for thread safety
    private let writeQueue = DispatchQueue(label: "com.punjabapp.videoRecorder", qos: .userInitiated)
    
    // MARK: - API
    
    func startRecording() {
        writeQueue.async { [weak self] in
            guard let self = self else { return }
            if self.isRecording { return }
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.outputUrl = documentsPath.appendingPathComponent("temp_story_recording_\(Date().timeIntervalSince1970).mov")
            
            // Remove existing file
            if let url = self.outputUrl, FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            
            // Do NOT setup writer here. Wait for first frame to get correct dimensions.
            self.assetWriter = nil
            self.videoInput = nil
            self.audioInput = nil
            self.pixelBufferAdaptor = nil
            
            self.isRecording = true
            self.startTime = .zero
        }
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        writeQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            guard self.isRecording else {
                completion(nil)
                return
            }
            
            self.isRecording = false
            
            guard let assetWriter = self.assetWriter, assetWriter.status == .writing else {
                print("❌ Stop Recording: Asset Writer not active or failed to start")
                completion(nil)
                return
            }
            
            // Finish writing
            self.videoInput?.markAsFinished()
            self.audioInput?.markAsFinished()
            
            assetWriter.finishWriting {
                DispatchQueue.main.async {
                    // Verify file exists and has size
                    if let url = self.outputUrl,
                       let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                       let size = attrs[.size] as? UInt64, size > 0 {
                        completion(url)
                    } else {
                        print("❌ Recording failed: File empty or missing. Writer Status: \(assetWriter.status.rawValue), Error: \(String(describing: assetWriter.error))")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func writeFrame(for pixelBuffer: CVPixelBuffer, time: TimeInterval) {
        // Need to retain buffer if passing to async block?
        // Actually buffer is valid during the call, but if we dispatch async, we should probably ensure it stays valid?
        // CVPixelBuffer is ref counted.
        
        writeQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.isRecording else { return }
            
            // Initialize Writer on first frame if needed
            if self.assetWriter == nil, let url = self.outputUrl {
                let width = CVPixelBufferGetWidth(pixelBuffer)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                self.setupAssetWriter(url: url, width: width, height: height)
            }
            
            guard let writer = self.assetWriter, writer.status == .writing, let adaptor = self.pixelBufferAdaptor else {
                return
            }
            
            let seconds = CMTime(seconds: time, preferredTimescale: 600)
            
            if self.startTime == .zero {
                self.startTime = seconds
                writer.startSession(atSourceTime: self.startTime)
                print("🎬 Video Writer Session Started at \(time) with size: \(CVPixelBufferGetWidth(pixelBuffer))x\(CVPixelBufferGetHeight(pixelBuffer))")
            }
            
            if self.videoInput?.isReadyForMoreMediaData == true {
                 if !adaptor.append(pixelBuffer, withPresentationTime: seconds) {
                     print("⚠️ Failed to append buffer: \(String(describing: writer.error))")
                 }
            }
        }
    }
    
    func writeAudio(sampleBuffer: CMSampleBuffer) {
        writeQueue.async { [weak self] in
            guard let self = self else { return }
            // Only write audio if writer is initialized (video started)
            guard self.isRecording, let writer = self.assetWriter, writer.status == .writing, let input = self.audioInput, self.startTime != .zero else { return }
            
            if input.isReadyForMoreMediaData {
                input.append(sampleBuffer)
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupAssetWriter(url: URL, width: Int, height: Int) {
        // ... (Keep existing implementation but called on serial queue)
        do {
            print("🔧 Setting up AssetWriter: \(width)x\(height)")
            assetWriter = try AVAssetWriter(outputURL: url, fileType: .mov)
            
            // Video Input
            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
            
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            videoInput?.expectsMediaDataInRealTime = true
            
            if let writer = assetWriter, writer.canAdd(videoInput!) {
                writer.add(videoInput!)
            }
            
            // Pixel Buffer Adaptor
            let sourcePixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
            
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput!, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            
            // Audio Input
            let audioSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 64000
            ]
            
            audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
            audioInput?.expectsMediaDataInRealTime = true
            
            if let writer = assetWriter, let input = audioInput, writer.canAdd(input) {
                writer.add(input)
            }
            
            assetWriter?.startWriting()
            
        } catch {
            print("❌ Asset Writer Setup Failed: \(error)")
        }
    }
}
