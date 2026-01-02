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
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        // Initial Tool
        canvasView.tool = PKInkingTool(toolType, color: UIColor(color), width: 5)
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Toggle interaction
        uiView.isUserInteractionEnabled = isDrawing
        uiView.tool = PKInkingTool(toolType, color: UIColor(color), width: 5)
    }
}
