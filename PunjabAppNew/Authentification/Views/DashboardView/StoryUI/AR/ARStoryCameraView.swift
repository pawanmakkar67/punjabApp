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
                // config.userFaceTrackingEnabled = true // DISABLED: To ensure no conflict with Vision
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
        var visionNode: SCNNode? // Node for Back Camera (Vision Tracking)
        
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
            
            // CLEANUP: Remove back camera vision node
            visionNode?.removeFromParentNode()
            visionNode = nil
            
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
            
            // CLEANUP: Remove previous vision node to force fresh recreation
            visionNode?.removeFromParentNode()
            visionNode = nil
            
            view.session.pause() // Stop previous session first
            let config = ARWorldTrackingConfiguration()
            config.providesAudioData = true // Enabled
            // config.isLightEstimationEnabled = true // Disabled for stability
            config.worldAlignment = .gravity
            
            if ARWorldTrackingConfiguration.supportsUserFaceTracking {
                // print("✅ Back Camera: User Face Tracking Supported")
                // config.userFaceTrackingEnabled = true // DISABLED: Tracks user, not subject
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
        
        // MARK: - Logic (Moved)
        
        func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
             let isFront = viewModel.isFrontCamera
             
             for (feature, indices) in zip(viewModel.features, viewModel.featureIndices) {
                 guard let child = node.childNode(withName: feature, recursively: false) as? FaceNode else { continue }
                 
                 if isFront {
                     // Front Camera (High Accuracy Mesh-Based)
                     let vertices = indices.map { anchor.geometry.vertices[$0] }
                     child.updatePosition(for: vertices)
                 } else {
                     // Back Camera (Fallback Manual Positioning - Manual Mode)
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
                     
                     // DEBUG: Add Red Sphere to Nose if missing
                     if feature == "nose" && child.childNode(withName: "debugSphere", recursively: false) == nil {
                         let sphere = SCNSphere(radius: 0.02) // 2cm radius * 5 scale = 10cm visual
                         sphere.firstMaterial?.diffuse.contents = UIColor.red
                         sphere.firstMaterial?.lightingModel = .constant
                         let sNode = SCNNode(geometry: sphere)
                         sNode.name = "debugSphere"
                         child.addChildNode(sNode)
                     }
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
             
             // Also apply to Vision Node
             if let vNode = visionNode {
                 applyFilterToNode(filter, node: vNode)
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
                    // RENDERING FIX: Revert to default lighting to check if .constant is the cause
                    // plane.firstMaterial?.lightingModel = .constant 
                    // plane.firstMaterial?.writesToDepthBuffer = false
                    // plane.firstMaterial?.readsFromDepthBuffer = false
                    
                    if let image = UIImage(named: filter.imageName) {
                        print("✅ Image Loaded: \(filter.imageName)")
                        plane.firstMaterial?.diffuse.contents = image
                        // plane.firstMaterial?.emission.contents = image 
                        // plane.firstMaterial?.transparencyMode = .aOne 
                    } else {
                        print("❌ Image FAILED to load: \(filter.imageName). Using fallback.")
                        plane.firstMaterial?.diffuse.contents = UIColor.clear
                    }
                    
                    plane.firstMaterial?.isDoubleSided = true
                    // plane.firstMaterial?.transparency = 1.0
                }
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
             // --- BACK CAMERA DEBUG ---
             // Force Manual Mode if Back Camera
             if !viewModel.isFrontCamera {
                  let zDist = anchor.transform.columns.3.z
                  DispatchQueue.main.async {
                      // self.viewModel.debugLog = "BACK CAM (MANUAL): Z: \(String(format: "%.2f", zDist))"
                  }
             }
             // -------------------------
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
                  // Re-enable HUD for loop verification
                  let z = faceAnchor.transform.columns.3.z
                  DispatchQueue.main.async { self.viewModel.debugLog = "Track Z: \(String(format: "%.2f", z))" }
             }
             

         }
         
         func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
             frameCounter += 1
             
             // Video Recording Logic
             if viewModel.isRecording {
                 // THROTTLE: Capture every 4th frame (~15 FPS) - 720p is lighter so we can do 15fps
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
                             let scale = image.scale
                             
                             // OPTIMIZATION: Downscale to max 720p width for performance
                             // Native scale is often 3x (~1170p), which is too heavy for CPU processing
                             let targetWidth: CGFloat = 720.0
                             let resizeFactor = min(1.0, targetWidth / (size.width * scale))
                             
                             let videoWidth = Int(size.width * scale * resizeFactor) / 2 * 2
                             let videoHeight = Int(size.height * scale * resizeFactor) / 2 * 2
                             
                             if let buffer = image.pixelBuffer(width: videoWidth, height: videoHeight) {
                                 self.viewModel.processFrame(buffer: buffer, time: CACurrentMediaTime())
                             }
                             self.isProcessingFrame = false
                         }
                     }
                 }
             }

             
             // VISION LOGIC (Back Camera Only)
             if !viewModel.isFrontCamera, let currentFrame = sceneView?.session.currentFrame {
                 // 1. Run Detection (Throttle to every 10th frame to reduce CPU load)
                 if frameCounter % 10 == 0 {
                     let capturedImage = currentFrame.capturedImage // retain buffer
                     DispatchQueue.global(qos: .userInitiated).async {
                         self.viewModel.detectFace(in: capturedImage)
                     }
                 }
                 
                 // 2. Update Position
                 if let faceRect = viewModel.detectedFaceRect {
                     // Lazy Init Node
                     if visionNode == nil {
                         visionNode = SCNNode()
                         visionNode?.name = "visionRoot"
                         sceneView?.scene.rootNode.addChildNode(visionNode!)
                         
                         // Create subs
                        let nose = FaceNode(with: viewModel.noseOptions, width: 0.06, height: 0.06)
                        nose.name = "nose"
                        nose.isHidden = true // Default Hidden
                        visionNode?.addChildNode(nose)
                        let glasses = FaceNode(with: viewModel.glassesOptions, width: 0.15, height: 0.06)
                        glasses.name = "glasses"
                        glasses.isHidden = true // Default Hidden
                        visionNode?.addChildNode(glasses)
                        let beard = FaceNode(with: viewModel.beardOptions, width: 0.22, height: 0.26)
                        beard.name = "beard"
                        beard.isHidden = true // Default Hidden
                        visionNode?.addChildNode(beard)
                    }
                    
                    visionNode?.isHidden = false
                    
                    // STATE FIX: Reset visibility and re-apply selection every frame
                    // 1. Hide all feature nodes first to prevent ghosts/stuck filters
                    visionNode?.childNodes.forEach { $0.isHidden = true }
                    
                    // 2. Apply current filter if exists
                    if let filter = viewModel.getSelectedFilter() {
                        applyFilterToNode(filter, node: visionNode!)
                    }
                    
                    // Convert Rect (Normalized Bottom-Left) to Screen Point
                    let bounds = sceneView!.bounds
                    let screenX = faceRect.midX * bounds.width
                    let screenY = (1.0 - faceRect.midY) * bounds.height
                    
                    // Unproject to World (Z = 0.5m in front of camera)
                    let projected = sceneView!.unprojectPoint(SCNVector3(screenX, screenY, 0.5)) // 0.5 is depth (0 near, 1 far)
                    visionNode?.position = projected
                    
                    // Make it look at camera
                    if let query = sceneView?.pointOfView {
                        visionNode?.look(at: query.position)
                    }
                    visionNode?.scale = SCNVector3(1.0, 1.0, 1.0) // Scale DOWN (from 3.0)
                 } else {
                     visionNode?.isHidden = true
                 }
             } else {
                 visionNode?.isHidden = true
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
