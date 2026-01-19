
import SwiftUI

struct StickerPickerView: View {
    @Environment(\.dismiss) var dismiss
    var onSelect: (String) -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    // Sample emoji stickers
    let stickers = [
        "😀", "😎", "🥳", "😍", "🔥", "💯", "🎉", "❤️",
        "😂", "🥺", "👍", "👎", "👋", "🙌", "✨", "💫",
        "🍕", "🍔", "🍦", "🍎", "🐶", "🐱", "🚗", "✈️",
        "🌸", "🌻", "⚽️", "🏀", "🎸", "🎧", "📷", "📱"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(stickers, id: \.self) { sticker in
                        Button {
                            onSelect(sticker)
                            dismiss()
                        } label: {
                            Text(sticker)
                                .font(.system(size: 50))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
