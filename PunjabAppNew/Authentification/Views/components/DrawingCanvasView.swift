//
//  DrawingCanvasView.swift
//  PunjabAppNew
//
//  Created by pc on 16/12/2025.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isDrawing: Bool
    var toolType: PKInkingTool.InkType = .pen
    var color: Color = .red
    var isEraser: Bool = false
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        // Initial Tool
        setTool(for: canvasView)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Toggle interaction
        uiView.isUserInteractionEnabled = isDrawing
        setTool(for: uiView)
    }
    
    private func setTool(for canvas: PKCanvasView) {
        if isEraser {
            canvas.tool = PKEraserTool(.vector)
        } else {
            canvas.tool = PKInkingTool(toolType, color: UIColor(color), width: 5)
        }
    }
}
