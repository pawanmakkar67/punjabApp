
import SwiftUI
import Kingfisher
import AVFoundation

struct VideoThumbnailView: View {
    let videoURL: URL
    let previewURL: URL?
    
    @State private var generatedThumbnail: UIImage?
    @State private var loadFailed = false
    
    var body: some View {
        ZStack {
            if let previewURL = previewURL, !loadFailed {
                KFImage(previewURL)
                    .resizable()
                    .placeholder {
                        Color.gray.opacity(0.3)
                    }
                    .onFailure { _ in
                        // If loading from server fails, try generating local thumbnail
                        loadFailed = true
                        generateThumbnail()
                    }
                    .scaledToFill()
            } else if let generatedThumbnail = generatedThumbnail {
                Image(uiImage: generatedThumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
                    .overlay(ProgressView())
            }
            
            // Play Icon Overlay
            Image(systemName: "play.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .shadow(radius: 2)
        }
        .onAppear {
            if previewURL == nil {
                generateThumbnail()
            }
        }
    }
    
    private func generateThumbnail() {
        Task {
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            // Allow loose time tolerance for faster generation
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 60)
            
            do {
                // Try grabbing the first frame (0.0) instead of 1.0 to ensure short videos work
                let time = CMTime.zero
                let cgImage = try await generator.image(at: time).image
                await MainActor.run {
                    self.generatedThumbnail = UIImage(cgImage: cgImage)
                }
            } catch {
                print("❌ Failed to generate thumbnail for \(videoURL): \(error.localizedDescription)")
            }
        }
    }
}
