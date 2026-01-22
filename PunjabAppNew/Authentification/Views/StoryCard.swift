import SwiftUI
import Kingfisher

struct StoryCard: View {
    @ObservedObject var viewModel: FeedViewModel
    @State private var startIndex: Int? = nil

    var body: some View {
            HStack(spacing: 10) {
                ForEach(Array(viewModel.storiesList.enumerated()), id: \.element.user_id) { idx, friend in
                    storyCardItem(for: friend, at: idx)
                }
            }
        .fullScreenCover(item: $startIndex, onDismiss: { startIndex = nil }) { idx in
            StoryViewer(stories: viewModel.storiesList, startIndex: idx) {
                startIndex = nil
            }
        }
    }
    
    // MARK: - Story Card Item
    @ViewBuilder
    private func storyCardItem(for friend: Stories, at index: Int) -> some View {
        ZStack(alignment: .bottomLeading) {
            storyBackground(for: friend)
            storyUserInfo(for: friend)
        }
        .frame(width: 120, height: 170)
        .cornerRadius(15)
        .onTapGesture {
            startIndex = index
        }
    }
    
    // MARK: - Story Background
    @ViewBuilder
    private func storyBackground(for friend: Stories) -> some View {
        let thumbnailURL = friend.stories_sub?.first?.thumbnail ?? friend.avatar ?? ""
        
        KFImage(URL(string: thumbnailURL))
            .placeholder {
                Image("no_profile")
                    .resizable()
            }
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 170)
            .clipped()
            .cornerRadius(15)
    }
    
    // MARK: - Story User Info
    @ViewBuilder
    private func storyUserInfo(for friend: Stories) -> some View {
        HStack(spacing: 8) {
            userAvatar(for: friend)
            userName(for: friend)
        }
        .padding(8)
    }
    
    // MARK: - User Avatar
    @ViewBuilder
    private func userAvatar(for friend: Stories) -> some View {
        KFImage(URL(string: friend.avatar ?? ""))
            .resizable()
            .frame(width: 35, height: 35)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppColors.themeColor, lineWidth: 3)
            )
    }
    
    // MARK: - User Name
    @ViewBuilder
    private func userName(for friend: Stories) -> some View {
        Text(friend.displayName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
    }
}


// make Int conform to Identifiable for fullScreenCover(item:)
extension Int: Identifiable {
    public var id: Int { self }
}


#Preview {
    StoryCard(viewModel: FeedViewModel())
}
