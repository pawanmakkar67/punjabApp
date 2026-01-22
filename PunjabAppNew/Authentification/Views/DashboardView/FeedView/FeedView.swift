//
//  ContentView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var scrollPosition: Int = 0
    @State private var showCreatePostView: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { proxy in
                    Color.white
                        .ignoresSafeArea()
                    VStack {
                        ScrollViewReader { proxy1 in
                            ScrollView {
                                HeaderView {
                                    showCreatePostView = true
                                } onSeachTap: {
                                    
                                }

                               
                                whatsOnYourMindView(viewModel: viewModel, width: proxy.size.width)
                                DividerView(widthRectangle: proxy.size.width)
                                StoryFeed(viewModel: viewModel)
                                DividerView(widthRectangle: proxy.size.width)
                                LazyVStack {
                                    ForEach(0 ..< viewModel.posts.count, id: \.self) { index in
                                        PostView(viewModel: viewModel, index: index, width: proxy.size.width)
                                            .onVisible {
                                                if (viewModel.posts.count - 4) == index {
                                                    viewModel.triggerLoadMoreIfNeeded(index)
                                                }
                                            }.preference(key: PostVisiblePreferenceKey.self,
                                                         value: [index: proxy.frame(in: .global).midY])
                                            .onPreferenceChange(PostVisiblePreferenceKey.self) { values in
                                                let screenMid = UIScreen.main.bounds.midY
                                                
                                                if let closest = values.min(by: {
                                                    abs($0.value - screenMid) < abs($1.value - screenMid)
                                                })?.key {
                                                    if viewModel.focusedIndex != closest {
                                                        viewModel.focusedIndex = closest
                                                    }
                                                }
                                            }
                                        DividerView(widthRectangle: proxy.size.width - 15)
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                            
                            .refreshable {
                                viewModel.posts = []
                                Task { try await viewModel.fetchPosts() }
                            }
                        }
                    }.fullScreenCover(isPresented: $showCreatePostView) {
                        CreatePostView(viewModel: viewModel, currentUser: viewModel.currentUser, width: proxy.size.width)
                    }
                }
            }
        }.onAppear {
            getNewsFeeds()
            getMe()
        }
    }
    func getNewsFeeds() {
        Task {
            await viewModel.fetchPosts()
        }
    }
    func getMe() {
        Task {
            await viewModel.fetchMe()
        }
    }
}

#Preview {
    FeedView()
}





//
//ScrollViewReader { proxy in
//    ScrollView {
//        LazyVStack {
//            ForEach(0 ..< viewModel.posts.count, id: \.self) { index in
//                PostView(viewModel: viewModel, index: index)
//                    .id(index)
//            }
//        }
//    }
//}
