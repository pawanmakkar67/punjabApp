//
//  CreatePostView.swift
//  FacebookClone
//
//  Created by omar thamri on 2/1/2024.
//

import SwiftUI
import Kingfisher
import PhotosUI
import AVKit

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPhotoPicker: Bool = false
    @State private var showVideoPicker: Bool = false
    @State private var showCameraPicker: Bool = false
    @State private var showLocationPicker: Bool = false
    @State private var showMusicPicker: Bool = false
    @State private var tempInput: String = ""
    @StateObject private var viewModel: FeedViewModel
    
    // Camera Result Holders
    @State private var cameraImage: UIImage?
    @State private var cameraVideoURL: URL?

    private var width: CGFloat
    init(viewModel: FeedViewModel,width: CGFloat) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.width = width
    }
    
    func getVideoURL() -> URL? {
        // If we have a direct file URL (from Camera), use it
        if let url = cameraVideoURL {
            return url
        }
        
        // If we have Data (from PhotosPicker), write to temp
        if let data = viewModel.videoData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
            do {
                try data.write(to: tempURL)
                return tempURL
            } catch {
                print("Error writing temp video: \(error)")
                return nil
            }
        }
        
        return nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Divider()
                        HStack(alignment: .top) {
                            ZStack {
                                Image("no-profile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                                KFImage(URL(string: viewModel.currentUser?.avatar ?? ""))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(Circle())
                            }
                                
                            VStack(alignment: .leading) {
                                HStack(spacing: 4) {
                                    Text(viewModel.currentUser?.displayName ?? "User")
                                        .fontWeight(.semibold)
                                    
                                    if !viewModel.postLocation.isEmpty {
                                        Text("is at")
                                            .foregroundStyle(.secondary)
                                        Text(viewModel.postLocation)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .font(.system(size: 16))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                
                                HStack {
                                    Menu {
                                        Button(action: { viewModel.postPrivacy = "Everyone" }) {
                                            Label("Everyone", systemImage: "globe")
                                        }
                                        Button(action: { viewModel.postPrivacy = "Friends" }) {
                                            Label("Friends", systemImage: "person.2.fill")
                                        }
                                    } label: {
                                        ChoicesView(
                                            leftImageName: viewModel.postPrivacy == "Everyone" ? "globe" : "person.2.fill",
                                            title: viewModel.postPrivacy
                                        )
                                    }
                                    
                                    ChoicesView(leftImageName: "", title: "Album")
                                }
                                ChoicesView(leftImageName: "camera", title: "Off")
                            }
                        }
                        .padding()
                        
                        TextField("What's on your mind?",text: $viewModel.mindText,axis: .vertical)
                            .padding(.horizontal)
                        
                        // Content Preview (Music Tags)
                        if !viewModel.postMusic.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    HStack {
                                        Image(systemName: "music.note")
                                            .foregroundColor(.orange)
                                        Text(viewModel.postMusic)
                                            .font(.subheadline)
                                        Button {
                                            viewModel.postMusic = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(15)
                                    .padding(.leading)
                                }
                            }
                            .padding(.top, 10)
                        }

                        // Media Preview
                        if viewModel.videoData != nil {
                             ZStack(alignment: .topTrailing) {
                                 if let url = getVideoURL() {
                                     VideoPlayer(player: AVPlayer(url: url))
                                        .frame(height: 300)
                                        .cornerRadius(10)
                                        .padding()
                                 } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 300)
                                        .cornerRadius(10)
                                        .padding()
                                        .overlay(Text("Preview Unavailable").foregroundColor(.gray))
                                 }
                                
                                Button(action: {
                                    viewModel.videoData = nil
                                    viewModel.selectedVideo = nil
                                    cameraVideoURL = nil // Clear camera url too
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(.black.opacity(0.5)))
                                }
                                .padding(.trailing, 25) // Adjust for padding() on ZStack content
                                .padding(.top, 25)
                             }
                        } else if viewModel.createPostImage != Image("") || viewModel.createPostSelectedImage != nil {
                             ZStack(alignment: .topTrailing) {
                                 viewModel.createPostImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width - 30, height: 300)
                                    .clipped()
                                    .padding(.leading)
                                    .padding(.top)
                                 
                                 Button(action: {
                                     viewModel.createPostImage = Image("")
                                     viewModel.createPostSelectedImage = nil
                                     viewModel.videoData = nil
                                 }) {
                                     Image(systemName: "xmark.circle.fill")
                                         .resizable()
                                         .frame(width: 25, height: 25)
                                         .foregroundStyle(.white)
                                         .background(Circle().fill(.black.opacity(0.5)))
                                 }
                                 .padding(.trailing, 10)
                                 .padding(.top, 20)
                             }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                
                Spacer()
                Divider()
                
                // Bottom Toolbar
                HStack(alignment: .bottom) {
                    Spacer()
                    // Camera
                    Button(action: { showCameraPicker.toggle() }) {
                        Image(systemName: "camera.fill")
                            .foregroundStyle(.blue)
                    }
                    Spacer()
                    // Photo
                    Button(action: { showPhotoPicker.toggle() }) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    // Video
                    Button(action: { 
                         viewModel.isReel = false
                         showVideoPicker.toggle() 
                    }) {
                        Image(systemName: "video.fill")
                            .foregroundStyle(.purple)
                    }
                    Spacer()
                    // Reel
                    Button(action: { 
                         viewModel.isReel = true
                         showVideoPicker.toggle() 
                    }) {
                        Image(systemName: "film")
                            .foregroundStyle(.pink)
                    }
                    Spacer()
                     // More Options including Music/Location
                    Menu {
                        Button(action: { showLocationPicker.toggle() }) {
                            Label("Location", systemImage: "mappin.and.ellipse")
                        }
                        Button(action: { showMusicPicker.toggle() }) {
                            Label("Music", systemImage: "music.note")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.white) // Ensure background captures taps/overlaps
            }
            .toolbar{
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            Button(action: {
                                viewModel.createPostImage = Image("")
                                viewModel.createPostSelectedImage = nil
                                viewModel.mindText = ""
                                dismiss()
                            }, label: {
                                Image(systemName: "arrow.left")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                            })
                            
                            Text("Create post")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                try await viewModel.uploadPost()
                                viewModel.createPostImage = Image("")
                                viewModel.createPostSelectedImage = nil
                                viewModel.mindText = ""
                                dismiss()
                                                }
                        }, label: {
                            Text("Post")
                                .frame(width: 80, height: 35)
                                .foregroundStyle(viewModel.mindText.count > 0 ? .white : Color(.darkGray))
                                .background(viewModel.mindText.count > 0 ? .blue : Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                        .disabled(viewModel.mindText.count == 0 && viewModel.createPostImage == Image("") && viewModel.videoData == nil)
                    }
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $viewModel.createPostSelectedImage, matching: .images)
            .photosPicker(isPresented: $showVideoPicker, selection: $viewModel.selectedVideo, matching: .videos)
            .fullScreenCover(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $cameraImage, videoURL: $cameraVideoURL)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(selectedLocation: $viewModel.postLocation)
            }
            .sheet(isPresented: $showMusicPicker) {
                MusicPickerView(selectedMusic: $viewModel.postMusic)
            }
            .onChange(of: cameraImage) { newImage in
                if let image = newImage {
                    viewModel.setPostImage(image)
                }
            }
            .onChange(of: cameraVideoURL) { newURL in
                if let url = newURL {
                    viewModel.setVideo(url: url)
                }
            }
        }
        }
}

#Preview {
    CreatePostView(viewModel: FeedViewModel(), width: 300)
}
