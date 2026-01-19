
import SwiftUI

struct MusicPickerView: View {
    @Environment(\.dismiss) var dismiss
    var onSelect: (String) -> Void // Passes back song name or ID
    
    // Mock Data
    let songs = [
        "Trending Song 1",
        "Happy Vibes",
        "Deep Focus",
        "Party Mix",
        "Chill Lofi",
        "Punjabi Hits",
        "Rock Anthem"
    ]
    
    var body: some View {
        NavigationView {
            List(songs, id: \.self) { song in
                Button {
                    onSelect(song)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundStyle(.blue)
                        Text(song)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "play.circle")
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
