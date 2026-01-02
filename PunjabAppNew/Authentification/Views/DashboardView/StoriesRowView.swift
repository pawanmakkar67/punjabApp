//
//  StoriesRowView.swift
//  PunjabAppNew
//
//  Created by pc on 21/11/25.
//

import SwiftUI

struct StoriesRowView: View {

    @ObservedObject var viewModel: FeedViewModel
    @Binding var selectedStory: Stories?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {

                ForEach(viewModel.storiesList) { story in
                    VStack(spacing: 8) {
                        Image(story.avatar ?? "")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .onTapGesture {
                                selectedStory = story
                            }

                        Text(story.username ?? "")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal)
        }
        .onAppear {
            if viewModel.storiesList.isEmpty {
                Task {
                   await viewModel.fetchStories()
                }
            }
        }
    }
}
