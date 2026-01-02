import SwiftUI
import UIKit

class HTMLTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        let size = self.sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
    }

    var preferredMaxLayoutWidth: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

struct HTMLText: UIViewRepresentable {
    let attributedText: NSAttributedString
    let maxWidth: CGFloat

    func makeUIView(context: Context) -> HTMLTextView {
        let tv = HTMLTextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }

    func updateUIView(_ uiView: HTMLTextView, context: Context) {
        uiView.attributedText = attributedText
        uiView.preferredMaxLayoutWidth = maxWidth
    }
}






func isVideo(path: String?) -> Bool {
    guard let ext = URL(string: path ?? "")?.pathExtension.lowercased() else {
        return false
    }
    
    let videoExtensions = ["mp4", "mov", "mpeg", "m4v"]
    return videoExtensions.contains(ext)
}

struct VisibleIndexKey: PreferenceKey {
    static var defaultValue: Int? = nil
    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        value = nextValue() ?? value
    }
}

struct PostVisiblePreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
