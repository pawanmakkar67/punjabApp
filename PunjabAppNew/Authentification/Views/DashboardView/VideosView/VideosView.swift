//
//  ContentView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI

struct VideosView: View {
    @StateObject private var viewModel = FeedViewModel()
    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { proxy in
                    Color.white
                        .ignoresSafeArea()
                    VStack {
                        ScrollView {

                        }
                        .scrollIndicators(.hidden)
                    }
                    .refreshable {
                        viewModel.posts = []
//                        Task { try await viewModel.fetchPosts() }
                    }
                }
            }
        }
    }
}

#Preview {
    VideosView()
}





