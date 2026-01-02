
import SwiftUI

struct MusicPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMusic: String
    @State private var searchText = ""
    
    struct Song: Identifiable {
        let id = UUID()
        let name: String
        let artist: String
    }
    
    let songs = [
        Song(name: "Diljit Dosanjh", artist: "Punjab Test"),
        Song(name: "Sidhu Moose Wala", artist: "Punjab Test"),
        Song(name: "Karan Aujla", artist: "Punjab Test"),
        Song(name: "AP Dhillon", artist: "Punjab Test"),
        Song(name: "Shape of You", artist: "Ed Sheeran"),
        Song(name: "Blinding Lights", artist: "The Weeknd"),
        Song(name: "Levitating", artist: "Dua Lipa"),
        Song(name: "Peaches", artist: "Justin Bieber")
    ]
    
    var filteredSongs: [Song] {
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredSongs) { song in
                Button(action: {
                    selectedMusic = "\(song.name) - \(song.artist)"
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text(song.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            Text(song.artist)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for music")
            .navigationTitle("Add Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
