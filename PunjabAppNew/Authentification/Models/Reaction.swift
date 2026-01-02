import SwiftUI

enum PostReaction: String, CaseIterable, Identifiable {
    case like
    case love
    case haha
    case wow
    case sad
    case angry
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .love: return "❤️"
        case .haha: return "😂"
        case .wow: return "😮"
        case .sad: return "😢"
        case .angry: return "😡"
        }
    }
    
    var color: Color {
        switch self {
        case .like: return .blue
        case .love: return .red
        case .haha: return .yellow
        case .wow: return .orange
        case .sad: return .yellow
        case .angry: return .orange
        }
    }
    
    var title: String {
        rawValue.capitalized
    }
    
    var apiValue: String {
        switch self {
        case .like: return "1"
        case .love: return "2"
        case .haha: return "3"
        case .wow: return "4"
        case .sad: return "5"
        case .angry: return "6"
        }
    }
}
