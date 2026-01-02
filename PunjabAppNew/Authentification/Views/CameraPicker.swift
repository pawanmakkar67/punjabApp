
import SwiftUI
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var videoURL: URL?
    @Environment(\.dismiss) var dismiss
    
    // allow selecting both images and video
    var mediaTypes: [String] = [UTType.image.identifier, UTType.movie.identifier]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = mediaTypes
        picker.allowsEditing = false
        // For video quality/duration if needed
        picker.videoQuality = .typeHigh
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let mediaType = info[.mediaType] as? String
            
            if mediaType == UTType.image.identifier {
                if let image = info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
            } else if mediaType == UTType.movie.identifier {
                if let videoUrl = info[.mediaURL] as? URL {
                    parent.videoURL = videoUrl
                }
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
