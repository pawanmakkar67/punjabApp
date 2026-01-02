import SwiftUI
import Kingfisher
import AVKit
import Combine

// MARK: - Video Player Manager
class VideoPlayerManager: ObservableObject {
    @Published var player: AVPlayer?
    @Published var isVideoReady: Bool = true
    @Published var storyDuration: TimeInterval = 5.0
    
    private var cancellables = Set<AnyCancellable>()
    
    func setupPlayer(url: URL, onReady: @escaping () -> Void, onEnded: @escaping () -> Void) {
        cleanup()
        
        isVideoReady = false
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe player status
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                if status == .readyToPlay {
                    self.isVideoReady = true
                    
                    // Update duration from video
                    if let duration = self.player?.currentItem?.duration.seconds, !duration.isNaN, duration > 0 {
                        self.storyDuration = min(duration, 45.0)
                    }
                    
                    self.player?.play()
                    onReady()
                } else if status == .failed {
                    self.isVideoReady = true
                }
            }
            .store(in: &cancellables)
        
        // Observe when video ends
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                onEnded()
            }
            .store(in: &cancellables)
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
}

struct StoryViewer: View {
    let stories: [Stories]                 // full list of users
    let startIndex: Int                    // user index tapped
    let onClose: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var userIndex: Int
    @State private var storyIndex: Int = 0

    // Timer settings
    @State private var progress: TimeInterval = 0
    @State private var isPaused: Bool = false

    // gestures
    @State private var dragOffset: CGSize = .zero
    
    // Video player manager
    @StateObject private var playerManager = VideoPlayerManager()
    
    // Interaction State
    @State private var isLiked: Bool = false
    @State private var selectedReaction: Reaction? = nil
    @State private var showReactionPicker: Bool = false
    @State private var showComments: Bool = false
    @State private var commentText: String = ""
    @State private var comments: [Comment] = []
    @State private var showShareSheet: Bool = false
    @FocusState private var isCommentFocused: Bool

    // timer publisher
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    init(stories: [Stories], startIndex: Int, onClose: @escaping () -> Void) {
        self.stories = stories
        self.startIndex = startIndex
        self._userIndex = State(initialValue: startIndex)
        self.onClose = onClose
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let url = currentStoryURL() {
                    if isCurrentStoryVideo() {
                        // Video content
                        VideoPlayer(player: playerManager.player)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .ignoresSafeArea()
                            .clipped()
                            .offset(y: dragOffset.height)
                            .onAppear {
                                playerManager.setupPlayer(url: url, onReady: {}) {
                                    if !isPaused {
                                        goToNextOrNextUser()
                                    }
                                }
                            }
                    } else {
                        // Image content
                        KFImage(url)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                            .ignoresSafeArea()
                            .clipped()
                            .offset(y: dragOffset.height)
                    }
                } else {
                    // fallback
                    Color.black
                }
                
                // Top progress bars
                VStack(spacing: 8) {
                    progressBars(width: geo.size.width)
                        .padding(.top, 44)
                        .padding(.horizontal, 8)
                    Spacer()
                }
                
                // Close button
                VStack {
                    HStack {
                        Button(action: closeAll) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
                
                // Tap zones (left/right/center) and drag gestures
                HStack(spacing: 0) {
                    // Left — previous
                    Color.clear.contentShape(Rectangle())
                        .frame(width: geo.size.width * 0.3)
                        .onTapGesture { previous() }
                    
                    // Middle — pause/resume on tap (or skip)
                    Color.clear.contentShape(Rectangle())
                        .frame(width: geo.size.width * 0.4)
                        .onTapGesture {
                            // single tap center = pause/resume
                            isPaused.toggle()
                        }
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.1).onChanged { _ in
                            isPaused = true
                        }.onEnded { _ in
                            isPaused = false
                        })
                    
                    // Right — next
                    Color.clear.contentShape(Rectangle())
                        .frame(width: geo.size.width * 0.3)
                        .onTapGesture { next() }
                }
                .ignoresSafeArea()
                
                // Interaction Bar
                VStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: 20) {
                        // Like / Reaction Button
                        VStack {
                            if showReactionPicker {
                                reactionPicker
                                    .transition(.scale.combined(with: .opacity))
                            }
                            
                            Button(action: toggleLike) {
                                Image(systemName: selectedReaction?.icon ?? (isLiked ? "heart.fill" : "heart"))
                                    .font(.system(size: 28))
                                    .foregroundColor(selectedReaction?.color ?? (isLiked ? .red : .white))
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.3).onEnded { _ in
                                withAnimation {
                                    showReactionPicker.toggle()
                                    isPaused = true
                                }
                            })
                        }
                        
                        // Comment Button
                        Button(action: {
                            showComments = true
                            isPaused = true
                        }) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        // Share Button
                        Button(action: {
                            showShareSheet = true
                            isPaused = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                // Comment Sheet Overlay
                if showComments {
                    Color.black.opacity(0.4).ignoresSafeArea()
                        .onTapGesture {
                            showComments = false
                            isPaused = false
                        }
                    
                    VStack {
                        Spacer()
                        commentSheet
                            .transition(.move(edge: .bottom))
                    }
                }
                
            } // ZStack
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            handleDragEnd(value: value, height: geo.size.height, width: geo.size.width)
                            dragOffset = .zero
                        }
                )
                .onReceive(timer) { _ in
                    guard !isPaused else { return }
                    // Don't progress timer if video is loading
                    guard playerManager.isVideoReady else { return }
                    progress += 0.05
                    if progress >= playerManager.storyDuration {
                        progress = 0
                        goToNextOrNextUser()
                    }
                }
                .onAppear {
                    progress = 0
                    isPaused = false
                    // Set video ready state based on content type
                    playerManager.isVideoReady = !isCurrentStoryVideo()
                    playerManager.storyDuration = 5.0
                }
                .onDisappear {
                    playerManager.cleanup()
                }
                .onChange(of: isPaused) { newValue in
                    if isCurrentStoryVideo() {
                        if newValue {
                            playerManager.pause()
                        } else {
                            playerManager.play()
                        }
                    }
                }
                .onChange(of: userIndex) { _ in
                    playerManager.cleanup()
                    storyIndex = 0
                    progress = 0
                }
                .onChange(of: storyIndex) { _ in
                    playerManager.cleanup()
                    progress = 0
                    // Reset video ready state
                    playerManager.isVideoReady = !isCurrentStoryVideo()
                    playerManager.storyDuration = 5.0
                }
                .sheet(isPresented: $showShareSheet, onDismiss: { isPaused = false }) {
                    if let url = currentStoryURL() {
                        ShareSheet(activityItems: [url])
                    }
                }
            } // GeometryReader
        }
    
    // MARK: - Interaction Views
    
    var reactionPicker: some View {
        HStack(spacing: 12) {
            ForEach(Reaction.allCases, id: \.self) { reaction in
                Button(action: {
                    selectReaction(reaction)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: reaction.icon)
                            .font(.system(size: 24))
                            .foregroundColor(reaction.color)
                        Text(reaction.rawValue)
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.bottom, 8)
    }
    
    var commentSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Comments")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    showComments = false
                    isPaused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            // Comments List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(comments) { comment in
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(comment.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text(comment.text)
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Text(comment.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .frame(maxHeight: 300)
            .background(Color.black)
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Add a comment...", text: $commentText)
                    .padding(10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .focused($isCommentFocused)
                    .submitLabel(.send)
                    .onSubmit(postComment)
                
                Button(action: postComment) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color.black)
        }
        .background(Color.black)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Interaction Logic
    
    private func toggleLike() {
        withAnimation {
            if isLiked {
                isLiked = false
                selectedReaction = nil
            } else {
                isLiked = true
                // Default like
            }
        }
    }
    
    private func selectReaction(_ reaction: Reaction) {
        withAnimation {
            selectedReaction = reaction
            isLiked = true
            showReactionPicker = false
            isPaused = false
        }
    }
    
    private func postComment() {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newComment = Comment(
            username: "You", // Replace with actual current user name
            text: commentText,
            timestamp: Date()
        )
        
        withAnimation {
            comments.append(newComment)
            commentText = ""
            isCommentFocused = false
        }
    }

    private func currentStoryURL() -> URL? {
        guard userIndex >= 0, userIndex < stories.count,
              let subs = stories[userIndex].stories_sub, !subs.isEmpty,
              storyIndex >= 0, storyIndex < subs.count,
              let f = subs[storyIndex].file_name ?? subs[storyIndex].thumbnail else {
            // fallback to avatar / thumbnail if available
            if userIndex >= 0, userIndex < stories.count {
                return URL(string: stories[userIndex].avatar ?? "")
            }
            return nil
        }
        return URL(string: subs[storyIndex].file_name ?? subs[storyIndex].thumbnail ?? "")
    }
    
    private func isCurrentStoryVideo() -> Bool {
        guard userIndex >= 0, userIndex < stories.count,
              let subs = stories[userIndex].stories_sub, !subs.isEmpty,
              storyIndex >= 0, storyIndex < subs.count else {
            return false
        }
        
        let currentStory = subs[storyIndex]
        
        // Check story_type field first
        if let storyType = currentStory.story_type {
            return storyType.lowercased().contains("video") || storyType == "video"
        }
        
        // Fallback: check file extension
        if let fileName = currentStory.file_name {
            let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "webm"]
            let ext = (fileName as NSString).pathExtension.lowercased()
            return videoExtensions.contains(ext)
        }
        
        return false
    }
    



    private func goToNextOrNextUser() {
        if let subs = stories[userIndex].stories_sub, storyIndex < subs.count - 1 {
            storyIndex += 1
        } else {
            // move to next user
            if userIndex < stories.count - 1 {
                userIndex += 1
            } else {
                // all done
                closeAll()
            }
        }
    }

    private func next() {
        isPaused = false
        progress = 0
        if let subs = stories[userIndex].stories_sub, storyIndex < subs.count - 1 {
            storyIndex += 1
        } else if userIndex < stories.count - 1 {
            userIndex += 1
        } else {
            closeAll()
        }
    }

    private func previous() {
        isPaused = false
        progress = 0
        if storyIndex > 0 {
            storyIndex -= 1
        } else if userIndex > 0 {
            userIndex -= 1
            // move to last story of previous user
            if let prevSubs = stories[userIndex].stories_sub {
                storyIndex = max(0, (prevSubs.count - 1))
            } else {
                storyIndex = 0
            }
        } else {
            // at very first story: optionally restart or stay
            progress = 0
        }
    }

    private func handleDragEnd(value: DragGesture.Value, height: CGFloat, width: CGFloat) {
        let vertical = value.translation.height
        let horizontal = value.translation.width

        // Swipe down to dismiss (threshold 120)
        if vertical > 120 && abs(vertical) > abs(horizontal) {
            closeAll()
            return
        }

        // Swipe left/right to move user (threshold 80)
        if horizontal < -80 {
            // swipe left -> next user
            if userIndex < stories.count - 1 {
                userIndex += 1
            } else {
                closeAll()
            }
        } else if horizontal > 80 {
            // swipe right -> previous user
            if userIndex > 0 {
                userIndex -= 1
            } else {
                // at first user: optionally do nothing
            }
        }
    }

    private func closeAll() {
        isPaused = true
        onClose()
        dismiss()
    }

    // top progress bars view
    @ViewBuilder
    private func progressBars(width: CGFloat) -> some View {
        HStack(spacing: 6) {
            if userIndex < stories.count {
                let subs = stories[userIndex].stories_sub ?? []
                ForEach(0 ..< max(1, subs.count), id: \.self) { i in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .foregroundColor(Color.white.opacity(0.3))
                            .frame(height: 3)

                        Capsule()
                            .foregroundColor(.white)
                            .frame(width: barWidth(for: i, total: subs.count, fullWidth: width), height: 3)
                            .animation(.linear(duration: 0.05), value: progress)
                    }
                }
            }
        }
    }

    private func barWidth(for index: Int, total: Int, fullWidth: CGFloat) -> CGFloat {
        // total spacing modeled roughly; this is visual and not exact to container width
        let totalSpacing: CGFloat = CGFloat(max(0, total - 1) * 6) + 16
        let available = max(10, fullWidth - totalSpacing)
        let oneWidth = available / CGFloat(total)
        if index < storyIndex {
            return oneWidth
        } else if index > storyIndex {
            return 0
        } else {
            // current bar width based on progress
            let pct = min(1.0, progress / playerManager.storyDuration)
            return oneWidth * CGFloat(pct)
        }
    }
}

// MARK: - Interaction Models

enum Reaction: String, CaseIterable {
    case like = "Like"
    case love = "Love"
    case haha = "Haha"
    case wow = "Wow"
    case sad = "Sad"
    case angry = "Angry"
    
    var icon: String {
        switch self {
        case .like: return "hand.thumbsup.fill"
        case .love: return "heart.fill"
        case .haha: return "face.smiling.inverse"
        case .wow: return "mouth.open" // SF Symbol approximation
        case .sad: return "face.dashed" // SF Symbol approximation
        case .angry: return "eyebrow" // SF Symbol approximation
        }
    }
    
    var color: Color {
        switch self {
        case .like: return .blue
        case .love: return .red
        case .haha: return .yellow
        case .wow: return .yellow
        case .sad: return .yellow
        case .angry: return .orange
        }
    }
}

struct Comment: Identifiable {
    let id = UUID()
    let username: String
    let text: String
    let timestamp: Date
}

// MARK: - Helpers

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
