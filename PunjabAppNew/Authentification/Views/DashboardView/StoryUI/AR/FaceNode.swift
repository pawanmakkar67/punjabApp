import SceneKit

class FaceNode: SCNNode {
    
    var options: [String]
    var index = 0
    
    init(with options: [String], width: CGFloat = 0.06, height: CGFloat = 0.06) {
        self.options = options
        
        super.init()
        
        let plane = SCNPlane(width: width, height: height)
        if let first = options.first {
            plane.firstMaterial?.diffuse.contents = UIImage(named: first)
        }
        plane.firstMaterial?.isDoubleSided = true
        
        // Enable transparency support
        plane.firstMaterial?.transparency = 1.0
        plane.firstMaterial?.transparencyMode = .aOne
        
        geometry = plane
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Custom functions

extension FaceNode {
    
    func updatePosition(for vectors: [vector_float3]) {
        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
        var finalPos = newPos
        
        // Add adjustments for specific features
        if name == "beard" {
            finalPos.y -= 0.092  // Move beard down by 8cm
            finalPos.x += 0.05  // Move beard ahead by 8cm
        }
        if name == "nose" {
            finalPos.y += 0.01
        }

        position = SCNVector3(finalPos)
    }
    
    func next() {
        index = (index + 1) % options.count
        
        if let plane = geometry as? SCNPlane {
            plane.firstMaterial?.diffuse.contents = UIImage(named: options[index])
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.transparency = 1.0
            plane.firstMaterial?.transparencyMode = .aOne
        }
    }
}
