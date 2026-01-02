//
//  MyStoryCard.swift
//  FacebookClone
//
//  Created by omar thamri on 2/1/2024.
//

import SwiftUI
import Kingfisher

struct MyStoryCard: View {
    @ObservedObject var viewModel: FeedViewModel

    @State private var showCreateStory: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 100, height: 170)
                .foregroundStyle(Color(.systemGray6))
            ZStack(alignment: .bottom) {
                ZStack {
                    Image("no_profile")
                        .resizable()
                        .frame(width: 100, height: 110)
                        .scaledToFill()
                        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, topTrailing: 15)))
                    if viewModel.uiImage == nil {
                        KFImage(URL(string: viewModel.currentUser?.avatar ?? ""))
                            .resizable()
                            .frame(width: 100, height: 110)
                            .scaledToFill()
                            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, topTrailing: 15)))
                    } else {
                        viewModel.profileImage
                            .resizable()
                            .frame(width: 100, height: 110)
                            .scaledToFit()
                            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 15, topTrailing: 15)))
                    }
                }
                VStack(spacing: 0) {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(.blue)
                        .clipShape(Circle())
                        .font(.system(size: 20,weight: .bold))
                        .overlay {
                            Circle()
                                .stroke(Color(.systemGray6),lineWidth: 3)
                        }
                    VStack {
                        Spacer()
                            .frame(height: 5)
                        Text("Create")
                        Text("story")
                    }
                    
                    .font(.system(size: 12,weight: .semibold))
                }
                .offset(y: 45)
            }
        }
        .onTapGesture {
            showCreateStory.toggle()
        }
        .fullScreenCover(isPresented: $showCreateStory) {
            CreateStoryView(viewModel: viewModel)
        }
    }
}

#Preview {
    MyStoryCard(viewModel: FeedViewModel())
}
