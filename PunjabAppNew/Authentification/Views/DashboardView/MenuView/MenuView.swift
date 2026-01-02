//
//  ContentView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = FeedViewModel()
//    private let user: User = User(userName: "pankajgaikar", userImage: "user_16")
    @State private var showCreatePostView: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ProfileHeader(user: viewModel.currentUser)
                        ProfileControlButtonsView()
                        ProfileMediaSelectionView(viewModel: viewModel)
                        //                    PostGridView(posts: MockData().posts)
                    }
                }
                .navigationBarTitle("", displayMode: .inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text(viewModel.currentUser?.displayName ?? "User")
                            .font(Font.system(size: 20, weight: .bold))
                            .padding()
                            .frame(width: UIScreen.main.bounds.size.width / 2, alignment: .leading)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                showCreatePostView = true
                            }) {
                                Image(systemName: "plus.app")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(.trailing, 10)
                            }
                            Image(systemName: "line.horizontal.3")
                                .resizable()
                                .frame(width: 25, height: 20)
                        }
                    }
                }).fullScreenCover(isPresented: $showCreatePostView) {
                    CreatePostView(viewModel: viewModel, width: proxy.size.width)
                }
            }
        }.onAppear {
            Task {
                await viewModel.fetchMe()
                await viewModel.fetchMyPosts()
//                await viewModel.fetchMyReels()
//                await viewModel.fetchMyPhotos()
//                await viewModel.fetchMyVideos()
            }
        }
    }
}

#Preview {
    MenuView()
}

