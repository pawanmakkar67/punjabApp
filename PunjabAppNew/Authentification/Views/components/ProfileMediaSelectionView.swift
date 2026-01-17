//
//  ProfileMediaSelectionView.swift
//  Instagram-SwiftUI
//
//  Created by Pankaj Gaikar on 23/05/21.
//

import SwiftUI
import Kingfisher
import AVKit

struct ProfileMediaSelectionView: View {
    @State private var selectedView = 0
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Tab Buttons
            HStack(alignment: .center, spacing: 8) {
                // Posts Tab
                Button(action:{
                    selectedView = 0
                }){
                    Image(systemName: selectedView == 0 ? "square.fill.text.grid.1x2" : "square.text.square")
                        .padding(.vertical, 2)
                        .font(.system(size: 30))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                
                // Grid Tab
                Button(action:{
                    selectedView = 1
                }){
                    Image(systemName: selectedView == 1 ? "square.grid.3x3.fill" : "square.grid.3x3")
                        .padding(.vertical, 2)
                        .font(.system(size: 30))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }

                // Videos Tab
                Button(action:{
                    selectedView = 2
                }){
                    Image(systemName: selectedView == 2 ? "film.fill" : "film")
                        .padding(.vertical, 2)
                        .font(.system(size: 30))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
                
                // Tagged Tab
                Button(action:{
                    selectedView = 3
                }){
                    Image(systemName: selectedView == 3 ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.checkmark")
                        .padding(.vertical, 2)
                        .font(.system(size: 30))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            Text("Debug: Selected Tab = \(selectedView), Posts: \(viewModel.myposts.count)")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(4)
            
            // Tab Content
            ZStack {
                if selectedView == 0 {
                    PostsListView(viewModel: viewModel)
                        .onAppear {
                            print("📱 Posts tab appeared")
                        }
                } else if selectedView == 1 {
                    MediaGridView(viewModel: viewModel, posts: viewModel.myphotos, showPlayIcon: false, onLoadMore: {
                        Task { await viewModel.fetchMyPhotos() }
                    })
                        .onAppear {
                            print("📱 Grid tab appeared - myphotos: \(viewModel.myphotos.count)")
                        }
                } else if selectedView == 2 {
                    MediaGridView(viewModel: viewModel, posts: viewModel.myvideos, showPlayIcon: true, onLoadMore: {
                        Task { await viewModel.fetchMyVideos() }
                    })
                        .onAppear {
                            print("📱 Videos tab appeared - myvideos: \(viewModel.myvideos.count)")
                        }
                } else if selectedView == 3 {
//                    TaggedView()
//                        .onAppear {
//                            print("📱 Tagged tab appeared")
//                        }
                    MediaGridView(viewModel: viewModel, posts: viewModel.myreels, showPlayIcon: true, onLoadMore: {
                        Task { await viewModel.fetchMyReels() }
                    })
                        .onAppear {
                            print("📱 Videos tab appeared - myvideos: \(viewModel.myvideos.count)")
                        }

                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            print("📱 ProfileMediaSelectionView appeared")
            print("📱 Initial selectedView: \(selectedView)")
            print("📱 myposts count: \(viewModel.myposts.count)")
            
            Task {
                await viewModel.fetchMyPosts()
               await viewModel.fetchMyVideos()
               await viewModel.fetchMyPhotos()
               await viewModel.fetchMyReels()

            }
        }
    }
}

// MARK: - Posts List View
struct PostsListView: View {
    @ObservedObject var viewModel: FeedViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.myposts.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 50) // Add some spacing
                    
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No Posts Yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Your posts will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        Task { try await viewModel.fetchMyPosts() }
                    }) {
                        Text("Retry Fetch")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.top)

                    Spacer()
                        .frame(height: 50)
                }
                .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(0 ..< viewModel.myposts.count, id: \.self) { index in
                        MyPostView(viewModel: viewModel, index: index, width: UIScreen.main.bounds.width)
                            .onAppear {
                                if index == viewModel.myposts.count - 1 {
                                    Task { await viewModel.fetchMyPosts() }
                                }
                            }
                        DividerView(widthRectangle: UIScreen.main.bounds.width - 15)
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            print("📱 PostsListView appeared - myposts count: \(viewModel.myposts.count)")
        }
    }
}

// MARK: - My Post View (Wrapper for PostView using myposts)
struct MyPostView: View {
    @ObservedObject var viewModel: FeedViewModel
    let index: Int
    let width: CGFloat
    
    var post: Post {
        viewModel.myposts[index]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Post Header
            HStack {
                ZStack {
                    Image("no_profile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    
                    if let avatar = post.publisher?.avatar {
                        KFImage(URL(string: avatar))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(post.publisher?.displayName ?? "Unknown User")
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Post Content
            if let text = post.postText, !text.isEmpty {
                HTMLText(
                    attributedText: viewModel.attributed(text),
                    maxWidth: width - 40
                ).frame(maxWidth: width - 40, alignment: .leading)
                    .padding(.horizontal, 20)
            }
            
            // Post Media
            if let file = post.postFile, !file.isEmpty {
                if isVideo(path: file) {
                    if let url = URL(string: file) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(width: width, height: width * 1.76)
                    }
                } else {
                    KFImage(URL(string: file))
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: width * 1.25)
                        .clipped()
                }
            }
            
            if let photos = post.photo_multi, !photos.isEmpty {
                AutoCarousel(photos: photos)
            }
            
            // Post Footer (likes, comments, shares)
            VStack {
                HStack {
                    HStack(spacing: 3) {
                        Image("like")
                            .resizable()
                            .frame(width: 18, height: 18)
                        Text(post.post_likes ?? "0")
                    }
                    Spacer()
                    HStack {
                        Text("\(post.post_comments ?? "0") comments")
                        Text("•")
                            .fontWeight(.bold)
                        Text("\(post.post_shares ?? "0") shares")
                    }
                }
                .foregroundStyle(Color(red: 66/255, green: 103/255, blue: 178/255))
                .font(.system(size: 12))
                .padding(.horizontal)
            }
        }
        .frame(width: width, alignment: .leading)
    }
}

// MARK: - Media Grid View
struct MediaGridView: View {
    @ObservedObject var viewModel: FeedViewModel
    let posts: [Post]
    let showPlayIcon: Bool
    var onLoadMore: (() -> Void)? = nil
    
    @State private var showFullScreenImage = false
    @State private var selectedImageIndex = 0
    @State private var selectedVideoItem: VideoWrapper?

    var allImageURLs: [String] {
        var urls: [String] = []
        for post in posts {
            if let file = post.postFile_full, !file.isEmpty, !isVideo(path: file) {
                urls.append(file)
            } else if let photos = post.photo_multi, !photos.isEmpty {
                if let first = photos.first?.image {
                    urls.append(first)
                }
            }
        }
        return urls
    }

    var body: some View {
        if posts.isEmpty {
            VStack {
                 Spacer()
                    .frame(height: 50)
                 Text("No Media")
                    .foregroundColor(.gray)
                 Spacer()
            }
        } else {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ], spacing: 2) {
                ForEach(posts.indices, id: \.self) { index in
                    if let file = posts[index].postFile_full, !file.isEmpty {
                        if isVideo(path: file) {
                            if let videoURL = URL(string: file) {
                                let thumbURL: URL? = {
                                    if let thumb = posts[index].postFile_full, !thumb.isEmpty {
                                        return URL(string: thumb)
                                    }
                                    return nil
                                }()
                                GeometryReader { geometry in
                                    VideoThumbnailView(videoURL: videoURL, previewURL: thumbURL)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                        .clipped()
                                        .onTapGesture {
                                            print("▶️ Tapped video: \(videoURL)")
                                            selectedVideoItem = VideoWrapper(url: videoURL)
                                        }
                                }
                                .aspectRatio(1, contentMode: .fit)
                                .onAppear {
                                    if index == posts.count - 1 {
                                        onLoadMore?()
                                    }
                                }
                            }
                        } else {
                             MediaGridItem(imageURL: file, isVideo: false)
                                .onTapGesture {
                                    if let imgIndex = allImageURLs.firstIndex(of: file) {
                                        selectedImageIndex = imgIndex
                                        showFullScreenImage = true
                                    }
                                }
                                .onAppear {
                                    if index == posts.count - 1 {
                                        onLoadMore?()
                                    }
                                }
                        }
                    } else if let photos = posts[index].photo_multi, !photos.isEmpty {
                        // Priority to multi-photo if postFile is empty
                        if let firstImage = photos.first?.image, !firstImage.isEmpty {
                            MediaGridItem(imageURL: firstImage, isVideo: false)
                                .onTapGesture {
                                    if let imgIndex = allImageURLs.firstIndex(of: firstImage) {
                                        selectedImageIndex = imgIndex
                                        showFullScreenImage = true
                                    }
                                }
                                .onAppear {
                                    if index == posts.count - 1 {
                                        onLoadMore?()
                                    }
                                }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenImage) {
                FullScreenImageView(imageURLs: allImageURLs, selectedIndex: $selectedImageIndex)
            }
            .sheet(item: $selectedVideoItem) { item in
                ZStack(alignment: .topTrailing) {
                    VideoPlayer(player: AVPlayer(url: item.url))
                        .ignoresSafeArea()
                    
                    Button {
                        selectedVideoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .shadow(radius: 2)
                    }
                }
            }
        }
    }
}

//
//struct MediaGridVideoView: View {
//    @ObservedObject var viewModel: FeedViewModel
//    let posts: [ReelsData]
//    let showPlayIcon: Bool
//    var onLoadMore: (() -> Void)? = nil
//    
//    @State private var showFullScreenImage = false
//    @State private var selectedImageIndex = 0
//    @State private var selectedVideoItem: VideoWrapper?
//
//    var allImageURLs: [String] {
//        var urls: [String] = []
//        for post in posts {
//            if let file = post.postFile_full, !file.isEmpty, !isVideo(path: file) {
//                urls.append(file)
//            }
//            
//        }
//        return urls
//    }
//
//    var body: some View {
//        if posts.isEmpty {
//            VStack {
//                 Spacer()
//                    .frame(height: 50)
//                 Text("No Media")
//                    .foregroundColor(.gray)
//                 Spacer()
//            }
//        } else {
//            LazyVGrid(columns: [
//                GridItem(.flexible(), spacing: 2),
//                GridItem(.flexible(), spacing: 2),
//                GridItem(.flexible(), spacing: 2)
//            ], spacing: 2) {
//                ForEach(posts.indices, id: \.self) { index in
//                    if let file = posts[index].postFile_full, !file.isEmpty {
//                        if isVideo(path: file) {
//                            if let videoURL = URL(string: file) {
//                                let thumbURL: URL? = {
//                                    if let thumb = posts[index].postFile_full, !thumb.isEmpty {
//                                        return URL(string: thumb)
//                                    }
//                                    return nil
//                                }()
//                                GeometryReader { geometry in
//                                    VideoThumbnailView(videoURL: videoURL, previewURL: thumbURL)
//                                        .frame(width: geometry.size.width, height: geometry.size.width)
//                                        .clipped()
//                                        .onTapGesture {
//                                            print("▶️ Tapped video: \(videoURL)")
//                                            selectedVideoItem = VideoWrapper(url: videoURL)
//                                        }
//                                }
//                                .aspectRatio(1, contentMode: .fit)
//                                .onAppear {
//                                    if index == posts.count - 1 {
//                                        onLoadMore?()
//                                    }
//                                }
//                            }
//                        } else {
//                             MediaGridItem(imageURL: file, isVideo: false)
//                                .onTapGesture {
//                                    if let imgIndex = allImageURLs.firstIndex(of: file) {
//                                        selectedImageIndex = imgIndex
//                                        showFullScreenImage = true
//                                    }
//                                }
//                                .onAppear {
//                                    if index == posts.count - 1 {
//                                        onLoadMore?()
//                                    }
//                                }
//                        }
//                    }
//
//                }
//            }
//            .fullScreenCover(isPresented: $showFullScreenImage) {
//                FullScreenImageView(imageURLs: allImageURLs, selectedIndex: $selectedImageIndex)
//            }
//            .sheet(item: $selectedVideoItem) { item in
//                ZStack(alignment: .topTrailing) {
//                    VideoPlayer(player: AVPlayer(url: item.url))
//                        .ignoresSafeArea()
//                    
//                    Button {
//                        selectedVideoItem = nil
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 30))
//                        .foregroundColor(.white)
//                        .padding()
//                        .shadow(radius: 2)
//                    }
//                }
//            }
//        }
//    }
//}


struct VideoWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Media Grid Item
struct MediaGridItem: View {
    let imageURL: String
    let isVideo: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                }
                
                if isVideo {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(8)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Tagged View
struct TaggedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Tagged Posts")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Posts you're tagged in will appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// Helper function for video detection
func isVideo(path: String) -> Bool {
    let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v"]
    // Handle URLs with query parameters by taking only the path component
    let urlString = path.components(separatedBy: "?")[0]
    let fileExtension = (urlString as NSString).pathExtension.lowercased()
    return videoExtensions.contains(fileExtension)
}

struct ProfileMediaSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMediaSelectionView(viewModel: FeedViewModel())
    }
}
