import SwiftUI
import ARKit
import SceneKit

struct ARStoryCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: FaceTrackingViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator // Re-enabled for Audio
        sceneView.automaticallyUpdatesLighting = true
        
        let configuration: ARConfiguration
        if viewModel.isFrontCamera {
            let config = ARFaceTrackingConfiguration()
            config.isLightEstimationEnabled = true
            config.providesAudioData = true // Enabled
            configuration = config
        } else {
            let config = ARWorldTrackingConfiguration()
            config.worldAlignment = .gravity
            config.providesAudioData = true // Enabled
            if ARWorldTrackingConfiguration.supportsUserFaceTracking {
                config.userFaceTrackingEnabled = true
            }
            configuration = config
        }
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        context.coordinator.sceneView = sceneView
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Handle Camera Switch Logic based on actual session configuration
        let currentConfig = uiView.session.configuration
        let isRunningFront = currentConfig is ARFaceTrackingConfiguration
        
        // If Model says Front but Config is NOT Front -> Switch to Front
        // If Model says Back (not Front) but Config IS Front -> Switch to Back
        // If Model says Front but Config is NOT Front -> Switch to Front
        // If Model says Back (not Front) but Config IS Front -> Switch to Back
        if !context.coordinator.isSwitching {
            if viewModel.isFrontCamera && !isRunningFront {
                print("🔄 Switching to Front Camera Configuration")
                context.coordinator.setFrontCamera(in: uiView)
            } else if !viewModel.isFrontCamera && isRunningFront {
                print("🔄 Switching to Back Camera Configuration")
                context.coordinator.setBackCamera(in: uiView)
            }
        }
        
        // Handle filter updates
        // Handle filter updates
        let selectedFilter = viewModel.getSelectedFilter()
        if selectedFilter != context.coordinator.lastAppliedFilter {
            if let filter = selectedFilter {
                 context.coordinator.applyFilter(filter, in: uiView)
            } else {
                 context.coordinator.hideAllFilters(in: uiView)
            }
            context.coordinator.lastAppliedFilter = selectedFilter
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate { // Added ARSessionDelegate
        var viewModel: FaceTrackingViewModel
        weak var sceneView: ARSCNView?
        var lastAppliedFilter: Filter?
        var frameCounter: Int = 0
        var isSwitching: Bool = false
        var isProcessingFrame: Bool = false
        
        init(viewModel: FaceTrackingViewModel) {
            self.viewModel = viewModel
            super.init()
            
            // Bind capture trigger
            self.viewModel.triggerCapture = { [weak self] in
                self?.capturePhoto()
            }
        }
        
        func setFrontCamera(in view: ARSCNView) {
            isSwitching = true
            view.session.pause() // Stop previous session first
            let config = ARFaceTrackingConfiguration()
            config.isLightEstimationEnabled = true
            config.providesAudioData = true // Enabled
            view.session.run(config, options: [.resetTracking, .removeExistingAnchors, .stopTrackedRaycasts])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isSwitching = false
            }
        }
        
        func setBackCamera(in view: ARSCNView) {
            isSwitching = true
            view.session.pause() // Stop previous session first
            let config = ARWorldTrackingConfiguration()
            config.providesAudioData = true // Enabled
            // config.isLightEstimationEnabled = true // Disabled for stability
            config.worldAlignment = .gravity
            
            if ARWorldTrackingConfiguration.supportsUserFaceTracking {
                print("✅ Back Camera: User Face Tracking Supported")
                config.userFaceTrackingEnabled = true
                DispatchQueue.main.async { self.viewModel.statusMessage = nil }
            } else {
                print("⚠️ Back Camera: Face Tracking NOT Supported")
                DispatchQueue.main.async {
                    self.viewModel.statusMessage = "Back Camera Face Filters require iPhone XS or newer."
                }
            }
            view.session.run(config, options: [.resetTracking, .removeExistingAnchors, .stopTrackedRaycasts])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isSwitching = false
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
             guard let device = renderer.device else { return nil }
             guard let faceAnchor = anchor as? ARFaceAnchor else {
                 return nil
             }
             
             print("👤 ARDelegate: Found Face Anchor. Camera: \(viewModel.isFrontCamera ? "Front" : "Back")")
             
             let faceGeometry = ARSCNFaceGeometry(device: device)
             let node = SCNNode(geometry: faceGeometry)
             
             
             // Initial transparent mask (Hidden)
             node.geometry?.firstMaterial?.fillMode = .lines
             node.geometry?.firstMaterial?.transparency = 0.0
             
             // --- BACK CAMERA DEBUG ---
             // If Back Camera (No Mesh Vertices), show a Red Sphere to prove position
             if faceAnchor.geometry.vertices.count == 0 {
                 let sphere = SCNSphere(radius: 0.05) // 5cm sphere
                 sphere.firstMaterial?.diffuse.contents = UIColor.red
                 let sphereNode = SCNNode(geometry: sphere)
                 // sphereNode.position = SCNVector3(0, 0, 0) // Center of face anchor
                 node.addChildNode(sphereNode)
                 print("📍 Back Camera: Added Red Debug Sphere")
                 
                 let zDist = anchor.transform.columns.3.z
                 print("📍 Anchor World Z: \(zDist)")
                 
                 DispatchQueue.main.async {
                     self.viewModel.debugLog = "ANCHOR FOUND! Z: \(String(format: "%.2f", zDist))"
                 }
             }
             // -------------------------
             
             // Use ViewModel options to create nodes
             
             // Use ViewModel options to create nodes
             
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
             
             // VISIBILITY FIX: Force nodes to look at camera (Billboard) -> ONLY FOR BACK CAMERA
             if faceAnchor.geometry.vertices.count == 0 {
                 let billboard = SCNBillboardConstraint()
                 billboard.freeAxes = .all
                 noseNode.constraints = [billboard]
                 glassesNode.constraints = [billboard]
                 beardNode.constraints = [billboard]
             }
             
             // Hide all nodes initially (no filter selected by default)
             noseNode.isHidden = true
             glassesNode.isHidden = true
             beardNode.isHidden = true
             
             updateFeatures(for: node, using: faceAnchor)
             
             // Apply current filter immediately to the new node
             if let selectedFilter = viewModel.getSelectedFilter() {
                 applyFilterToNode(selectedFilter, node: node)
             }
             
             return node
         }
         
         func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
             guard let faceAnchor = anchor as? ARFaceAnchor,
                 let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                     return
                 }
             faceGeometry.update(from: faceAnchor.geometry)
             updateFeatures(for: node, using: faceAnchor)
             
             if frameCounter % 60 == 0 {
                  let z = faceAnchor.transform.columns.3.z
                  // Reduced logging frequency
                  // DispatchQueue.main.async { self.viewModel.debugLog = "Track Z: \(String(format: "%.2f", z))" }
             }
             

         }
         
         func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
             frameCounter += 1
             
             // Video Recording Logic
             if viewModel.isRecording {
                 // THROTTLE: Capture only every 4th frame (~15 FPS) to save memory
                 // FLOW CONTROL: Drop frame if previous is still processing
                 if frameCounter % 4 == 0 && !isProcessingFrame {
                     isProcessingFrame = true
                     
                     DispatchQueue.main.async { [weak self] in
                         guard let self = self else { return }
                         guard let image = self.sceneView?.snapshot() else {
                             self.isProcessingFrame = false
                             return
                         }
                         
                         DispatchQueue.global(qos: .userInitiated).async {
                             let size = image.size
                             let videoWidth = Int(size.width * image.scale) / 2 * 2
                             let videoHeight = Int(size.height * image.scale) / 2 * 2
                             
                             if let buffer = image.pixelBuffer(width: videoWidth, height: videoHeight) {
                                 self.viewModel.processFrame(buffer: buffer, time: CACurrentMediaTime())
                             }
                             self.isProcessingFrame = false
                         }
                     }
                 }
             }
         }
        
        // MARK: - ARSessionDelegate
        

        
        // MARK: - ARSessionDelegate
        
        func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
            viewModel.processAudio(buffer: audioSampleBuffer)
        }

        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            var message: String? = nil
            switch camera.trackingState {
            case .notAvailable:
                message = "Tracking unavailable"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion: message = "Too much motion"
                case .insufficientFeatures: message = "Point at a face / Improve lighting"
                case .initializing: message = "Initializing..."
                case .relocalizing: message = "Relocalizing..."
                @unknown default: message = "Tracking limited"
                }
            case .normal:
                message = nil // Clear message when normal
            }
            
            DispatchQueue.main.async {
                // Only override if not set (or use specific logic, here just feedback)
                if let msg = message {
                    self.viewModel.statusMessage = msg
                } else if self.viewModel.statusMessage == "Initializing..." {
                    self.viewModel.statusMessage = nil
                }
            }
        }
        
        // MARK: - Logic
        
        func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
             let vertexCount = anchor.geometry.vertices.count
             let useVertices = vertexCount > 0
             
             for (feature, indices) in zip(viewModel.features, viewModel.featureIndices) {
                 guard let child = node.childNode(withName: feature, recursively: false) as? FaceNode else { continue }
                 
                 if useVertices {
                     // Front Camera (High Accuracy)
                     let vertices = indices.map { anchor.geometry.vertices[$0] }
                     child.updatePosition(for: vertices)
                 } else {
                     // Back Camera (Fallback Manual Positioning)
                     // Approximate static offsets relative to face center
                     var offset = SCNVector3Zero
                     
                     switch feature {
                     case "nose":
                         offset = SCNVector3(0, 0, 0.1)
                     case "glasses":
                         offset = SCNVector3(0, 0.05, 0.1)
                     case "beard":
                         offset = SCNVector3(0, -0.1, 0.1)
                     default:
                         break
                     }
                     
                     child.position = offset
                     child.scale = SCNVector3(5.0, 5.0, 5.0) // SUPER SCALE for visibility
                     
                     // print("📍 Back Camera Update: \(feature) at \(offset)")
                 }
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
                applyFilterToNode(filter, node: node)
            }
        }
        
        func applyFilterToNode(_ filter: Filter, node: SCNNode) {
            let featureName: String
            switch filter.type {
            case .nose: featureName = "nose"
            case .glasses: featureName = "glasses"
            case .beard: featureName = "beard"
            }
            
            if let featureNode = node.childNode(withName: featureName, recursively: true) as? FaceNode {
                print("🎨 Applying Filter: \(featureName). Unhiding node.")
                featureNode.isHidden = false
                featureNode.index = 0
                
                if let plane = featureNode.geometry as? SCNPlane {
                    // RENDERING FIX: Use Emission (ignores lighting) + Disable Depth Test (Always on top)
                    plane.firstMaterial?.lightingModel = .constant // Flat rendering
                    plane.firstMaterial?.writesToDepthBuffer = false
                    plane.firstMaterial?.readsFromDepthBuffer = false
                    
                    if let image = UIImage(named: filter.imageName) {
                        plane.firstMaterial?.diffuse.contents = image
                        plane.firstMaterial?.emission.contents = image // Self-illuminated
                    } else {
                        // Keep blue fallback
                        plane.firstMaterial?.diffuse.contents = UIColor.blue
                        plane.firstMaterial?.emission.contents = UIColor.blue
                    }
                    
                    plane.firstMaterial?.isDoubleSided = true
                    plane.firstMaterial?.transparency = 1.0
                    // plane.firstMaterial?.transparencyMode = .aOne // Default is better for emission
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
