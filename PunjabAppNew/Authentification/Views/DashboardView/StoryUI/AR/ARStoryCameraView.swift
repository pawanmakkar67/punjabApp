import SwiftUI
import ARKit
import SceneKit

struct ARStoryCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: FaceTrackingViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator // Critical for video buffer updates
        sceneView.automaticallyUpdatesLighting = true
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.providesAudioData = true
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        context.coordinator.sceneView = sceneView
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Handle filter updates
        if let selectedFilter = viewModel.getSelectedFilter() {
             context.coordinator.applyFilter(selectedFilter, in: uiView)
        } else {
             context.coordinator.hideAllFilters(in: uiView)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var viewModel: FaceTrackingViewModel
        weak var sceneView: ARSCNView?
        
        init(viewModel: FaceTrackingViewModel) {
            self.viewModel = viewModel
            super.init()
            
            // Bind capture trigger
            self.viewModel.triggerCapture = { [weak self] in
                self?.capturePhoto()
            }
        }
        
        func capturePhoto() {
            guard let image = sceneView?.snapshot() else { return }
            DispatchQueue.main.async {
                self.viewModel.capturedImage = image
            }
        }
        
        // MARK: - ARSCNViewDelegate
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
             let device: MTLDevice!
             device = MTLCreateSystemDefaultDevice()
             guard let faceAnchor = anchor as? ARFaceAnchor else {
                 return nil
             }
             let faceGeometry = ARSCNFaceGeometry(device: device)
             let node = SCNNode(geometry: faceGeometry)
             
             // Initial transparent mask
             node.geometry?.firstMaterial?.fillMode = .lines // Debug Only? Or keep hidden?
             // Reference code sets transparency to 0, effectively hiding it but keeping it for mesh updates
             node.geometry?.firstMaterial?.transparency = 0.0
             
             // Use ViewModel options to create nodes
             let noseNode = FaceNode(with: viewModel.noseOptions, width: 0.06, height: 0.06)
             noseNode.name = "nose"
             node.addChildNode(noseNode)
             
             let glassesNode = FaceNode(with: viewModel.glassesOptions, width: 0.15, height: 0.06)
             glassesNode.name = "glasses"
             node.addChildNode(glassesNode)
             
             let beardNode = FaceNode(with: viewModel.beardOptions, width: 0.22, height: 0.26)
             beardNode.name = "beard"
             node.addChildNode(beardNode)
             
             // Hide all nodes initially (no filter selected by default)
             noseNode.isHidden = true
             glassesNode.isHidden = true
             beardNode.isHidden = true
             
             updateFeatures(for: node, using: faceAnchor)
             
             return node
         }
         
         func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
             guard let faceAnchor = anchor as? ARFaceAnchor,
                 let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                     return
             }
             
             faceGeometry.update(from: faceAnchor.geometry)
             updateFeatures(for: node, using: faceAnchor)
         }
        
        // MARK: - ARSessionDelegate
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Video Recording
             if viewModel.isRecording {
                 // Snapshotting SCNView is heavy, but required for AR capture per reference
                 DispatchQueue.main.async {
                     guard let image = self.sceneView?.snapshot() else { return }
                     
                     // Offload processing
                     DispatchQueue.global(qos: .userInitiated).async {
                         // Calculate dimensions (must be even)
                         let size = image.size
                         let videoWidth = Int(size.width * image.scale) / 2 * 2
                         let videoHeight = Int(size.height * image.scale) / 2 * 2
                         
                         if let buffer = image.pixelBuffer(width: videoWidth, height: videoHeight) {
                              self.viewModel.processFrame(buffer: buffer, time: CACurrentMediaTime())
                         }
                     }
                 }
             }
        }
        
        func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
             viewModel.processAudio(buffer: audioSampleBuffer)
        }
        
        // MARK: - Logic
        
        func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
             for (feature, indices) in zip(viewModel.features, viewModel.featureIndices) {
                 let child = node.childNode(withName: feature, recursively: false) as? FaceNode
                 let vertices = indices.map { anchor.geometry.vertices[$0] }
                 child?.updatePosition(for: vertices)
             }
         }
        
        func hideAllFilters(in sceneView: ARSCNView) {
             sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                 for feature in viewModel.features {
                     if let featureNode = node.childNode(withName: feature, recursively: true) {
                         featureNode.isHidden = true
                     }
                 }
             }
         }
        
        func applyFilter(_ filter: Filter, in sceneView: ARSCNView) {
            // First hide all
            hideAllFilters(in: sceneView)
            
            let featureName: String
            switch filter.type {
            case .nose: featureName = "nose"
            case .glasses: featureName = "glasses"
            case .beard: featureName = "beard"
            }
            
            sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                if let featureNode = node.childNode(withName: featureName, recursively: true) as? FaceNode {
                    featureNode.isHidden = false
                    featureNode.index = 0
                    
                    if let plane = featureNode.geometry as? SCNPlane {
                        plane.firstMaterial?.diffuse.contents = UIImage(named: filter.imageName)
                        plane.firstMaterial?.isDoubleSided = true
                        plane.firstMaterial?.transparency = 1.0
                        plane.firstMaterial?.transparencyMode = .aOne
                    }
                }
            }
        }
    }
}

// Add PixelBuffer extension (needed for video recording from UIImage)
extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                        width,
                                        height,
                                        kCVPixelFormatType_32ARGB,
                                        attrs as CFDictionary,
                                        &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                    space: rgbColorSpace,
                                    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
