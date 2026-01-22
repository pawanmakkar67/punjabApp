import SwiftUI
import AVKit
import Kingfisher
import PhotosUI
struct PostView: View {
   
    
    let facebookBlue = Color(red: 66/255, green: 103/255, blue: 178/255)
       @ObservedObject var viewModel: FeedViewModel
       let index: Int
       let width: CGFloat
       
       @State private var player: AVPlayer? = nil

        // Interaction State
        @State private var selectedReaction: PostReaction? = nil
        @State private var showReactions: Bool = false
        @State private var showComments: Bool = false
        @State private var showShareSheet: Bool = false
        @State private var commentText: String = ""
        @State private var comments: [CommentAPIModel] = []
        @State private var selectedCommentItem: PhotosPickerItem?
        @State private var commentImageData: Data?
        @State private var replyingTo: CommentAPIModel?


    
    var body: some View {
        if index < 0 || index >= viewModel.posts.count {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                
                headerView

                // MARK: --- TEXT
                if let text = viewModel.posts[index].postText,
                   !text.isEmpty {
                    HTMLText(
                        attributedText: viewModel.attributed(text),
                        maxWidth: width - 40
                    ).frame(maxWidth: width - 40, alignment: .leading)
                        .padding(.horizontal, 20)
                }
                // MARK: --- IMAGE / VIDEO
                if let file = viewModel.posts[index].postFile,
                   !file.isEmpty {
                    
                    if isVideo(path: file) {
                        videoPlayer(file)
                    } else {
                        postImage(file)
                    }
                }
                if let file = viewModel.posts[index].photo_multi,
                   !file.isEmpty {
                    AutoCarousel(photos: file)
                }
                
                // MARK: --- MAP
                if let location = viewModel.posts[index].postMap, !location.isEmpty {
                    PostMapView(locationName: location)
                        .padding(.horizontal)
                }
                footerView
                    .frame(maxWidth: width)
                
            }
            .frame(width: width, alignment: .leading).background(
                VisibilityDetector(index: index, viewModel: viewModel)
            )
            .onAppear {
                checkUserReaction()
            }
        }
    }
    
    // MARK: - VIDEO
    @ViewBuilder
    private func videoPlayer(_ filePath: String) -> some View {
        if let url = URL(string: filePath) {
            VideoPlayer(player: player)
                .frame(width: width, height: width * 1.76)
                .onAppear {
                    if player == nil {
                        player = AVPlayer(url: url)
                        player?.actionAtItemEnd = .pause
                    }
                    updatePlayState()
                }
                .onChange(of: viewModel.focusedIndex) { _ in
                    updatePlayState()
                }
                .onDisappear {
                    player?.pause()
                }
        }
    }
    
    private func updatePlayState() {
        if viewModel.focusedIndex == index {
            player?.play()
        } else {
            player?.pause()
        }
    }

    // MARK: - IMAGE
    @ViewBuilder
    private func postImage(_ filePath: String) -> some View {
        KFImage(URL(string: filePath))
            .resizable()
            .scaledToFill()
            .frame(width: width, height: width * 1.25 )
            .clipped()
    }
    
    // MARK: - HEADER
    private var headerView: some View {
        HStack {
            if let user = viewModel.posts[index].publisher {
                NavigationLink(destination: PublicProfileView(user: user)) {
                    headerContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                headerContent
            }
        }
        .padding(.horizontal)
    }
    
    private var headerContent: some View {
        HStack {
            ZStack {
                Image("no_profile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                KFImage(URL(string: viewModel.posts[index].publisher?.avatar ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.posts[index].publisher?.displayName ?? "Unknown User")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                HStack(spacing: 5) {
                    Text("1 d")
                    Circle()
                        .frame(width: 2, height: 2)
                    Image(systemName: "globe")
                }
                .font(.system(size: 12))
                .foregroundStyle(facebookBlue)
            }
            
            Spacer()
            
            HStack(spacing: 24) {
                Image(systemName: "ellipsis")
                Image(systemName: "xmark")
            }
            .fontWeight(.bold)
            .foregroundStyle(Color(.darkGray))
        }
    }
    
    // MARK: - FOOTER
    private var footerView: some View {
        VStack {
            HStack {
                HStack(spacing: 3) {
                    Image("like")
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text(viewModel.posts[index].post_likes ?? "0")
                }
                Spacer()
                HStack {
                    Text("\(viewModel.posts[index].post_comments ?? "0") comments")
                    Text("•")
                        .fontWeight(.bold)
                    Text("\(viewModel.posts[index].post_shares ?? "0") shares")
                }
            }
            .foregroundStyle(facebookBlue)
            .font(.system(size: 12))
            .padding(.horizontal)
            
            Divider()
                .background(.white.opacity(0.5))
            
            HStack {
                ZStack(alignment: .top) {
                    Button(action: toggleLike) {
                        if let reaction = selectedReaction {
                            HStack {
                                Text(reaction.emoji)
                                    .font(.system(size: 20))
                                Text(reaction.title)
                                    .foregroundColor(reaction.color)
                            }
                        } else {
                            actionButton(image: "hand.thumbsup", title: "Like", color: .gray)
                        }
                    }
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showReactions = true
                                }
                            }
                    )
                    
                    if showReactions {
                        VStack {
                            ReactionView { reaction in
                                withAnimation {
                                    selectedReaction = reaction
                                    showReactions = false
                                }
                                Task {
                                    let postId = viewModel.posts[index].post_id ?? viewModel.posts[index].id ?? ""
                                    if !postId.isEmpty {
                                        await viewModel.reactToPost(postID: postId, reaction: reaction.apiValue)
                                    }
                                }
                            }
                        }
                        .offset(y: -70)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                        .onTapGesture {
                            // Prevent dismissing when tapping reactions
                        }
                    }
                }
                Spacer()
                Button(action: { showComments = true }) {
                    actionButton(image: "message", title: "Comment", color: .gray)
                }
                Spacer()
                Button(action: { /* Send action */ }) {
                    actionButton(image: "icone-messager-noir", title: "Send", isCustomImage: true, color: .gray)
                }
                Spacer()
                Button(action: { showShareSheet = true }) {
                    actionButton(image: "arrowshape.turn.up.right", title: "Share", color: .gray)
                }
            }
            .font(.system(size: 14)).frame(width: width-40, alignment: .leading)
            .padding(.horizontal)
            .background(
                Group {
                    if showReactions {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    showReactions = false
                                }
                            }
                    }
                }
            )
            .sheet(isPresented: $showComments) {
                commentSheet
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = URL(string: viewModel.posts[index].postFile ?? "") {
                    ShareSheet(activityItems: [url])
                } else if let text = viewModel.posts[index].postText {
                    ShareSheet(activityItems: [text])
                }
            }
        }
    }
    
    


    private func actionButton(image: String, title: String, isCustomImage: Bool = false, color: Color? = nil) -> some View {
        HStack {
            if isCustomImage {
                Image(image)
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: image)
                    .foregroundColor(color)
            }
            Text(title)
                .foregroundColor(color)
        }
    }
    
    private func toggleLike() {
        let postId = viewModel.posts[index].post_id ?? viewModel.posts[index].id ?? ""
        withAnimation {
            if let current = selectedReaction {
                selectedReaction = nil
                Task {
                    if !postId.isEmpty {
                        await viewModel.reactToPost(postID: postId, reaction: "")
                    }
                }
            } else {
                selectedReaction = .like
                Task {
                    if !postId.isEmpty {
                        await viewModel.reactToPost(postID: postId, reaction: PostReaction.like.apiValue)
                    }
                }
            }
            showReactions = false
        }
    }
    
    private func checkUserReaction() {
        // Safe check for valid index
        guard index >= 0, index < viewModel.posts.count else { return }
        
        if let reaction = viewModel.posts[index].reaction,
           reaction.is_reacted == true,
           let type = reaction.type {
            
            // Match by API Value (1, 2, 3...)
            if let match = PostReaction.allCases.first(where: { $0.apiValue == type }) {
                selectedReaction = match
            } 
            // Match by name (Like, Love...) - fallback
            else if let match = PostReaction.allCases.first(where: { 
                $0.rawValue.caseInsensitiveCompare(type) == .orderedSame 
            }) {
                selectedReaction = match
            }
            // "woww" special case if needed
            else if type == "woww", let match = PostReaction.allCases.first(where: { $0.rawValue == "wow" }) {
                 selectedReaction = match
            }
        } else if let isLiked = viewModel.posts[index].is_liked, isLiked {
             // Fallback if reaction object is missing but is_liked is true
             selectedReaction = .like
        }
    }
    
    var commentSheet: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Comments")
                        .font(.headline)
                    Spacer()
                    Button(action: { showComments = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .onAppear {
                fetchComments()
            }
            
            // Comments List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            KFImage(URL(string: comment.userData?.avatar ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.userData?.username ?? "User")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text(comment.text ?? "")
                                    .font(.body)
                                
                                if let time = comment.time {
                                    Text(time)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Button(action: {
                                    replyingTo = comment
                                }) {
                                    Text("Reply")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Replies
                        if let replies = comment.replies, !replies.isEmpty {
                            ForEach(replies) { reply in
                                HStack(alignment: .top, spacing: 12) {
                                    KFImage(URL(string: reply.userData?.avatar ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 24, height: 24)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(reply.userData?.username ?? "User")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                        
                                        Text(reply.text ?? "")
                                            .font(.caption)
                                        
                                        if let time = reply.time {
                                            Text(time)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.leading, 50) // Indent replies
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            
            // Input Area
            VStack {
                if let replying = replyingTo {
                    HStack {
                        Text("Replying to \(replying.userData?.username ?? "User")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: { replyingTo = nil }) {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                
                if let data = commentImageData, let uiImage = UIImage(data: data) {
                    HStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .clipped()
                        
                        Button(action: {
                            selectedCommentItem = nil
                            commentImageData = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedCommentItem, matching: .images) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Write a comment...", text: $commentText)
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                        .submitLabel(.send)
                        .onSubmit(postComment)
                    
                    Button(action: postComment) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && commentImageData == nil)
                }
                .padding()
            }
            .onChange(of: selectedCommentItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            commentImageData = data
                        }
                    }
                }
            }
        }
    }
    
    private func postComment() {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || commentImageData != nil else { return }
        
        // Note: Real apps usually wait for server response or use optimistic update with a temporary ID.
        // For now, we clear input and fetch comments again after a delay or just rely on the user to pull to refresh if we implemented that.
        // Or we can manually append a fake model.
        
        let pid = viewModel.posts[index].post_id ?? viewModel.posts[index].id ?? ""
        let text = commentText
        let image = commentImageData
        
        let currentReply = replyingTo
        
        commentText = ""
        selectedCommentItem = nil
        commentImageData = nil
        replyingTo = nil
        
        Task {
            if let replyComment = currentReply {
                await viewModel.createReply(commentID: replyComment.id ?? "", text: text, imageData: image)
            } else {
                await viewModel.createComment(postID: pid, text: text, imageData: image)
            }
            await fetchComments() // Refresh list
        }
    }
    
    private func fetchComments() {
        let pid = viewModel.posts[index].post_id ?? viewModel.posts[index].id ?? ""
        guard !pid.isEmpty else { return }
        Task {
            let fetched = await viewModel.fetchComments(postID: pid)
            withAnimation {
                comments = fetched
            }
        }
    }
}

