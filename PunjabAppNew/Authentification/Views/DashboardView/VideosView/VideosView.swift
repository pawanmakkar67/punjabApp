//
//  ContentView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI
import AVKit

struct VideosView: View {
    @StateObject private var viewModel = FeedViewModel()
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if viewModel.reels.isEmpty && viewModel.isFetching {
                    ProgressView()
                } else if viewModel.reels.isEmpty {
                    Text("No reels available")
                        .foregroundColor(.gray)
                } else {
                    MediaGridVideoView(viewModel: viewModel, posts: viewModel.reels, showPlayIcon: true, onLoadMore: {
                        Task { await viewModel.fetchReels() }
                    })
                }
            }
            .navigationTitle("Videos")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.reels.isEmpty {
                    Task { await viewModel.fetchReels() }
                }
            }
        }
    }
}

// MARK: - Media Grid Video View
struct MediaGridVideoView: View {
    @ObservedObject var viewModel: FeedViewModel
    let posts: [ReelsData]
    let showPlayIcon: Bool
    var onLoadMore: (() -> Void)? = nil
    
    @State private var selectedReelIndex: Int?
    
    // Columns for 3x3 Grid
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(posts.indices, id: \.self) { index in
                    if let file = posts[index].postFile_full, !file.isEmpty {
                        
                        let videoURL = URL(string: file)
                        
                        GeometryReader { geometry in
                            if let vUrl = videoURL {
                                ZStack(alignment: .topTrailing) {
                                    VideoThumbnailView(videoURL: vUrl, previewURL: vUrl)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                        .clipped()
                                    
                                    if showPlayIcon {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                            .padding(8)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    print("▶️ Tapped reel at index: \(index)")
                                    selectedReelIndex = index
                                }
                            }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .onAppear {
                            if index == posts.count - 4 {
                                onLoadMore?()
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: Binding(
            get: { selectedReelIndex.map { ReelIndexWrapper(index: $0) } },
            set: { selectedReelIndex = $0?.index }
        )) { wrapper in
            ReelsPlayerView(viewModel: viewModel, initialIndex: wrapper.index)
        }
    }
}

struct ReelIndexWrapper: Identifiable {
    let id = UUID()
    let index: Int
}

// MARK: - Vertical Reels Player View
struct ReelsPlayerView: View {
    @ObservedObject var viewModel: FeedViewModel
    @State var currentIndex: Int
    @Environment(\.presentationMode) var presentationMode
    
    init(viewModel: FeedViewModel, initialIndex: Int) {
        self.viewModel = viewModel
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(viewModel.reels.indices, id: \.self) { index in
                    if let file = viewModel.reels[index].postFile_full, let url = URL(string: file) {
                         ReelPlayerItemView(url: url)
                            .tag(index)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .rotationEffect(.degrees(-90)) // Counter-rotate content
                            .onAppear {
                                if index == viewModel.reels.count - 2 {
                                    Task { await viewModel.fetchReels() }
                                }
                            }
                    } else {
                        Color.black.tag(index)
                    }
                }
            }
            .rotationEffect(.degrees(90), anchor: .center) // Rotate TabView to make it vertical
            .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width) // Swap dimensions
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Close Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.top, 40)
            .padding(.leading, 16)
        }
    }
}

struct ReelPlayerItemView: View {
    let url: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        GeometryReader { proxy in
            if let player = player {
                VideoPlayer(player: player)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .onAppear {
                        player.play()
                        print("▶️ Playing reel: \(url)")
                    }
                    .onDisappear {
                        player.pause()
                        print("⏸️ Paused reel")
                    }
            } else {
                ProgressView()
                    .onAppear {
                        let newPlayer = AVPlayer(url: url)
                        self.player = newPlayer
                        newPlayer.play()
                    }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    VideosView()
}





