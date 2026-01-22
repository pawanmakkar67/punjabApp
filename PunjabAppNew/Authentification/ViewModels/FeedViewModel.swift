//
//  FeedViewModel.swift
//  FacebookClone
//
//  Created by omar thamri on 7/1/2024.
//

import Foundation
import PhotosUI
import SwiftUI
import Firebase
import Combine
import Kingfisher
import ObjectMapper

@MainActor
class FeedViewModel: ObservableObject {
    @Published var selectedImage: PhotosPickerItem? {
            didSet { Task {try await loadImage(fromItem: selectedImage)} }
        }
    @Published var selectedCoverImage: PhotosPickerItem? {
            didSet { Task {try await loadCoverImage(fromItem: selectedCoverImage)} }
        }
    @Published var createPostSelectedImage: PhotosPickerItem? {
            didSet { Task {try await loadCreatePostImage(fromItem: createPostSelectedImage)} }
        }
    @Published var profileImage: Image = Image("no_profile")
    @Published var coverImage: Image = Image("no_profile")
    @Published var createPostImage: Image = Image("")
    @Published var createStoryImage: Image = Image("")
    
    @Published var createStorySelectedImage: PhotosPickerItem? {
        didSet { Task { try await loadCreateStoryImage(fromItem: createStorySelectedImage) } }
    }
    
    @Published var selectedVideo: PhotosPickerItem? {
        didSet { Task { await loadVideo(fromItem: selectedVideo) } }
    }
    @Published var videoData: Data?
    @Published var isReel: Bool = false
    @Published var postLocation: String = ""
    @Published var postPrivacy: String = "Everyone"
    @Published var postMusic: String = ""
    @Published var postFeeling: String = ""
    @Published var mindText: String = ""
    
    var uiImage: UIImage?
    @Published var storyUiImage: UIImage?
    @Published var storyVideoURL: URL?
    
    @Published var friends: [User]?
    @Published var currentUser: User_data?
    
    @Published var posts = [Post]()
    @Published var myposts = [Post]()
    @Published var myvideos = [Post]()
    @Published var myphotos = [Post]()
    @Published var myreels = [Post]()

    @Published var storiesList = [Stories]()
    @Published var isLoadingStories = false

    private var cancellables = Set<AnyCancellable>()
    @Published var isLoading = false
    @Published var hasMorePosts = true
    @Published var hasMorePhotos = true
    @Published var hasMoreVideos = true
    @Published var hasMoreReels = true
    @Published var reels = [ReelsData]()
    @Published var hasMoreGlobalReels = true
    @Published var followingList = [User_data]()
    @Published var followersList = [User_data]()

    @Published private(set) var isFetching = false
    @Published var focusedIndex: Int? = nil
    private var lastTriggeredIndex: Int?
    private var loadMoreWorkItem: DispatchWorkItem?
    var htmlCache: [String: NSAttributedString] = [:]

    func attributed(_ html: String) -> NSAttributedString {
        if let cached = htmlCache[html] {
            return cached
        }

        let parsed = parseHTML(html)
        htmlCache[html] = parsed
        return parsed
    }

    private func parseHTML(_ html: String) -> NSAttributedString {
        guard let data = html.data(using: .utf8) else { return NSAttributedString(string: html) }
        
        do {
            return try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            print("⚠️ Error parsing HTML: \(error.localizedDescription)")
            return NSAttributedString(string: html)
        }
    }

    init() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.currentUser = user
        }
        .store(in: &cancellables)
        UserService.shared.$friends.sink { [weak self] friends in
            self?.friends = friends
        }
        .store(in: &cancellables)
        self.currentUser = UserDefaults.standard.loadUser()
        if UserDefaults.standard.isUserCacheExpired() {
            Task { await fetchMe() }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RefreshFeed"), object: nil, queue: .main) { [weak self] _ in
            Task {
                await self?.fetchMe()
                await self?.fetchPosts()
            }
        }
    }

    @MainActor
    func reactToPost(postID: String, reaction: String) async {
        let params: [String: Any] = [
            "post_id": postID,
            "action": "reaction",
            "reaction": reaction
        ]
        
        do {
             let _: ActionResponse = try await APIManager.shared.request(
                url: APIList.reaction,
                parameters: params,
                model: ActionResponse.self
            )
        } catch {
            print("❌ Error sending reaction:", error.localizedDescription)
        }
    }

    @MainActor
    func createComment(postID: String, text: String, imageData: Data? = nil) async {
        var params: [String: Any] = [
            "post_id": postID,
            "type": "create",
            "text": text
        ]
        
        do {
            if let data = imageData {
                params.updateValue(imageData, forKey: "image_url")
                 let _: ActionResponse = try await APIManager.shared.uploadRequest(
                    url: APIList.comments,
                    parameters: params,
                    data: data,
                    name: "image_url",
                    fileName: "comment_image.jpg",
                    mimeType: "image/jpeg",
                    model: ActionResponse.self
                )
            } else {
                 let _: ActionResponse = try await APIManager.shared.request(
                    url: APIList.comments,
                    parameters: params,
                    model: ActionResponse.self
                )
            }
        } catch {
            print("❌ Error creating comment:", error.localizedDescription)
        }
    }

    @MainActor
    func fetchComments(postID: String) async -> [CommentAPIModel] {
        let params: [String: Any] = [
            "post_id": postID,
            "type": "fetch_comments"
        ]
        
        do {
            let response: CommentsResponse = try await APIManager.shared.request(
                url: APIList.comments,
                parameters: params,
                model: CommentsResponse.self
            )
            return response.data ?? []
        } catch {
            print("❌ Error fetching comments:", error.localizedDescription)
            return []
        }
    }

    func createReply(commentID: String, text: String, imageData: Data? = nil) async {
        var params: [String: Any] = [
            "comment_id": commentID,
            "type": "create_reply",
            "text": text
        ]
        
        do {
            if let data = imageData {
                params.updateValue(data, forKey: "image_url")
                 let _: ActionResponse = try await APIManager.shared.uploadRequest(
                    url: APIList.comments,
                    parameters: params,
                    data: data,
                    name: "image_url",
                    fileName: "reply_image.jpg",
                    mimeType: "image/jpeg",
                    model: ActionResponse.self
                )
            } else {
                 let _: ActionResponse = try await APIManager.shared.request(
                    url: APIList.comments,
                    parameters: params,
                    model: ActionResponse.self
                )
            }
        } catch {
            print("❌ Error creating reply:", error.localizedDescription)
        }
    }

    func uploadPost() async throws {
        var params: [String: Any] = [:]

        if mindText != "" {
            params["postText"] = mindText
        }

        if postMusic != "" {
            params["postMusic"] = postMusic
        }
        if postFeeling != "" {
            params["postFeeling"] = postFeeling
        }
        if postLocation != "" {
            params["postMap"] = postLocation
        }
        if isReel {
            params["is_reel"] = "1"
        }
        
        // Determine upload type
        if let video = videoData {
             let _: ActionResponse = try await APIManager.shared.uploadRequest(
                url: APIList.new_post,
                parameters: params,
                data: video,
                name: "postFile",
                fileName: "video.mp4",
                mimeType: "video/mp4",
                model: ActionResponse.self
            )
        } else if let image = uiImage, createPostSelectedImage != nil {
             guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
             let _: ActionResponse = try await APIManager.shared.uploadRequest(
                url: APIList.new_post,
                parameters: params,
                data: imageData,
                name: "postFile",
                fileName: "image.jpg",
                mimeType: "image/jpeg",
                model: ActionResponse.self
            )
        } else {
            // Text only
            let _: ActionResponse = try await APIManager.shared.request(
                 url: APIList.new_post,
                 parameters: params,
                 model: ActionResponse.self
            )
        }
        
        // Reset state
        await MainActor.run {
            self.mindText = ""
            self.createPostSelectedImage = nil
            self.createPostImage = Image("")
            self.selectedVideo = nil
            self.videoData = nil
            self.postLocation = ""
            self.postPrivacy = "Everyone"
            self.postMusic = ""
            self.postFeeling = ""
            self.isReel = false
        }
        
        // Refresh feed
        await fetchMe()
    }

    func uploadStory(fileType: String, fileData: Data) async throws {
        // Construct parameters
        let params: [String: Any] = [
            "file_type": fileType
        ]
        
        let fileName = fileType == "video" ? "story_video.mp4" : "story_image.jpg"
        let mimeType = fileType == "video" ? "video/mp4" : "image/jpeg"
        
        let response: storyModel = try await APIManager.shared.uploadRequest(
            url: APIList.createStory,
            parameters: params,
            data: fileData,
            name: "file",
            fileName: fileName,
            mimeType: mimeType,
            model: storyModel.self
        )
        print("📸 Upload Story Response: \(response.toJSON())")
        
        // Refresh stories
        await fetchStories()
    }
    
    func loadImage(fromItem item: PhotosPickerItem?) async throws{
            guard let item = item else { return }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.uiImage = uiImage
            self.profileImage = Image(uiImage: uiImage)
            try await updateProfileImage()
    }
    func loadCoverImage(fromItem item: PhotosPickerItem?) async throws{
        guard let item = item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.coverImage = Image(uiImage: uiImage)
        try await updateCoverImage()
    }
    
    func loadCreatePostImage(fromItem item: PhotosPickerItem?) async throws{
            guard let item = item else { return }
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.uiImage = uiImage
            self.createPostImage = Image(uiImage: uiImage)
           // try await updateCreatePostImage()
    }
    
    func loadCreateStoryImage(fromItem item: PhotosPickerItem?) async throws {
        guard let item = item else { return }
        
        // Check for Video
        // Attempting to load as movie file
        if let movie = try? await item.loadTransferable(type: VideoPickerTransferable.self) {
            await MainActor.run {
                self.storyVideoURL = movie.url
                self.storyUiImage = nil
                self.createStoryImage = Image("")
            }
            return
        }
        
        // Try Image
        if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
            await MainActor.run {
                self.storyUiImage = uiImage
                self.createStoryImage = Image(uiImage: uiImage)
                self.storyVideoURL = nil // Clear video if image selected
            }
            return
        }
    }
    
    struct VideoPickerTransferable: Transferable {
        let url: URL
        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(contentType: .movie) { movie in
                SentTransferredFile(movie.url)
            } importing: { received in
                let copy = URL.documentsDirectory.appending(path: "story_video.mp4")
                if FileManager.default.fileExists(atPath: copy.path()) {
                    try? FileManager.default.removeItem(at: copy)
                }
                try FileManager.default.copyItem(at: received.file, to: copy)
                return Self(url: copy)
            }
        }
    }
    
    func loadVideo(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
             print("📹 Video Loaded: \(data.count) bytes")
             await MainActor.run { self.videoData = data }
        } else {
             print("❌ Failed to load video data")
        }
    }
    
    // Use this when we get a video URL from the Camera
    func setVideo(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            print("📹 Video Loaded from URL: \(data.count) bytes")
            self.videoData = data
            self.isReel = false // Default to false, can be toggled
        } catch {
            print("❌ Failed to load video data from URL: \(error.localizedDescription)")
        }
    }

    // Use this when we get an image from the Camera
    func setPostImage(_ image: UIImage) {
        self.uiImage = image
        self.createPostImage = Image(uiImage: image)
        self.createPostSelectedImage = nil // Reset picker selection to avoid conflict
        self.videoData = nil // Clear any video
    }

    private func updateProfileImage() async throws {
//            guard let image = self.uiImage else { return }
//            guard let imageUrl = try? await ImageUploader.uploadImage(image) else { return }
//            try await UserService.shared.updateUserProfileImage(withImageUrl: imageUrl)
            
    }
    private func updateCoverImage() async throws {
//            guard let image = self.uiImage else { return }
//            guard let imageUrl = try? await ImageUploader.uploadImage(image) else { return }
//            try await UserService.shared.updateUserCoverImage(withImageUrl: imageUrl)
            
    }
    
    @MainActor
    func fetchMe() async {
        let userID = UserDefaults.getUserID() ?? ""
        
        let params = ["fetch":"user_data", "user_id":userID, "send_notify":"1"]

        do {
            // Move API call off main thread
            let result: userModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: userModel = try await APIManager.shared.request(
                            url: APIList.getUserDetails,
                            parameters: params,
                            model: userModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let userData = result.user_data {
                    // UI update back on main
                    UserDefaults.standard.saveUser(userData)

                    await MainActor.run {
                        currentUser = userData
                    }
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }


        
    }
    
    @MainActor
    func fetchPosts() async {
        guard !isFetching && hasMorePosts else { return }
        isFetching = true
        
        let userID = UserDefaults.getUserID() ?? ""
        
        var params: [String: Any] = [
            "type": "get_news_feed",
            "user_id": userID,
            "limit": "20"
        ]

        if let lastID = posts.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: FeedModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: FeedModel = try await APIManager.shared.request(
                            url: APIList.posts,
                            parameters: params,
                            model: FeedModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        posts.append(contentsOf: newPosts)
                    }
                } else {
                    hasMorePosts = false
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isFetching = false
    }
    
    @MainActor
    func fetchMyPosts(userID: String? = nil) async {
        guard !isFetching && hasMorePosts else { return }
        isFetching = true
        
        isLoading = true
        let targetID = userID ?? UserDefaults.getUserID() ?? ""
        
        print("📱 Fetching my posts for user: \(userID)")
        
        var params: [String: Any] = [
            "type": "get_user_posts",  // or get_user_posts
            "id": targetID,
            "limit": "20"
        ]

        if let lastID = myposts.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: FeedModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: FeedModel = try await APIManager.shared.request(
                            url: APIList.posts,
                            parameters: params,
                            model: FeedModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            print("📱 API Response - Status: \(result.api_status ?? 0)")
            
            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    print("📱 Received \(newPosts.count) posts")
                    // UI update back on main
                    await MainActor.run {
                        myposts.append(contentsOf: newPosts)
                        print("📱 Total myposts now: \(myposts.count)")
                    }
                } else {
                    print("📱 No posts returned from API")
                    hasMorePosts = false
                }
            } else {
                print("📱 API returned non-200 status: \(result.api_status ?? 0)")
            }

        } catch {
            print("❌ Error fetching my posts:", error.localizedDescription)
        }

        isLoading = false
        isFetching = false
    }
    
    @MainActor
    func fetchMyPhotos(userID: String? = nil) async {
        guard !isFetching && hasMorePhotos else { return }
        isFetching = true
        
        let targetID = userID ?? UserDefaults.getUserID() ?? ""
        
        var params: [String: Any] = [
            "postType": "photos",
            "publisher_id": targetID,
            "publisher_type": "user",
            "limit": "20"
        ]

        if let lastID = myphotos.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: myPostsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: myPostsModel = try await APIManager.shared.request(
                            url: APIList.getFilteredPosts,
                            parameters: params,
                            model: myPostsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        myphotos.append(contentsOf: newPosts)
                    }
                } else {
                    hasMorePhotos = false
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isFetching = false
    }

    @MainActor
    func fetchMyVideos(userID: String? = nil) async {
        guard !isFetching && hasMoreVideos else { return }
        isFetching = true
        
        let targetID = userID ?? UserDefaults.getUserID() ?? ""
        
        var params: [String: Any] = [
            "postType": "video",
            "publisher_id": targetID,
            "publisher_type": "user",
            "limit": "20"
        ]

        if let lastID = myvideos.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: myPostsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: myPostsModel = try await APIManager.shared.request(
                            url: APIList.getFilteredPosts,
                            parameters: params,
                            model: myPostsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        myvideos.append(contentsOf: newPosts)
                    }
                } else {
                    hasMoreVideos = false
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isFetching = false
    }
    
    @MainActor
    func fetchMyReels(userID: String? = nil) async {
        guard !isFetching && hasMoreReels else { return }
        isFetching = true
        
        let targetID = userID ?? UserDefaults.getUserID() ?? ""
        
        var params: [String: Any] = [
            "postType": "reels",
            "publisher_id": targetID,
            "publisher_type": "user",
            "limit": "20"
        ]
        
        if let lastID = myreels.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: myPostsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: myPostsModel = try await APIManager.shared.request(
                            url: APIList.getFilteredPosts,
                            parameters: params,
                            model: myPostsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        myreels.append(contentsOf: newPosts)
                    }
                } else {
                    hasMoreReels = false
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isFetching = false
    }
    
    @MainActor
    func fetchReels() async {
        guard !isFetching && hasMoreGlobalReels else { return }
        isFetching = true
        
        var params: [String: Any] = [
            "limit": "20"
        ]
        
        if let lastID = reels.last?.id {
            params["after_post_id"] = lastID
        }

        do {
            // Move API call off main thread
            let result: ReelsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: ReelsModel = try await APIManager.shared.request(
                            url: APIList.getReels,
                            parameters: params,
                            model: ReelsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        reels.append(contentsOf: newPosts)
                        print("🎬 Fetched \(newPosts.count) reels")
                    }
                } else {
                    hasMoreGlobalReels = false
                    print("🎬 No more reels")
                }
            }

        } catch {
            print("❌ Error fetching reels:", error.localizedDescription)
        }

        isFetching = false
    }

    @MainActor
    func fetchFollowing() async {
        let userID = UserDefaults.getUserID() ?? ""
        
        let params: [String: Any] = [
            "user_id": userID,
            "type": "following"
        ]
        
        do {
            let result: FriendsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: FriendsModel = try await APIManager.shared.request(
                            url: APIList.sendFriendRequest,
                            parameters: params,
                            model: FriendsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if result.api_status == 200 {
                if let users = result.data?.following {
                    await MainActor.run {
                        followingList = users
                    }
                }
            }
        } catch {
            print("❌ Error fetching following list:", error.localizedDescription)
        }
    }

    @MainActor
    func fetchFollowers() async {
        let userID = UserDefaults.getUserID() ?? ""
        
        let params: [String: Any] = [
            "user_id": userID,
            "type": "followers"
        ]
        
        do {
            let result: FriendsModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: FriendsModel = try await APIManager.shared.request(
                            url: APIList.sendFriendRequest,
                            parameters: params,
                            model: FriendsModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if result.api_status == 200 {
                if let users = result.data?.followers {
                    await MainActor.run {
                        followersList = users
                    }
                }
            }
        } catch {
            print("❌ Error fetching followers list:", error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchStories() async {
//        guard !isFetching && hasMorePosts else { return }
//        isFetching = true
        storiesList.removeAll()
        let userID = UserDefaults.getUserID() ?? ""
        
        var params: [String: Any] = [
            "type": "get_news_feed",
            "user_id": userID,
            "limit": "20"
        ]

//        if let lastID = posts.last?.id {
//            params["after_post_id"] = lastID
//        }

        do {
            // Move API call off main thread
            let result: storyModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: storyModel = try await APIManager.shared.request(
                            url: APIList.stories,
                            parameters: params,
                            model: storyModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }

            if result.api_status == 200 {
                if let newPosts = result.stories, !newPosts.isEmpty {
                    // UI update back on main
                    await MainActor.run {
                        storiesList.append(contentsOf: newPosts)
                    }
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isLoadingStories = false
    }
    
    

    func triggerLoadMoreIfNeeded(_ index: Int) {
        print("index ==>",index)
        guard hasMorePosts, !isFetching, index == posts.count - 4 else { return }
        if lastTriggeredIndex == index { return } // already triggered
        lastTriggeredIndex = index

        // Cancel previous
        loadMoreWorkItem?.cancel()

        // Debounce 300ms
        let item = DispatchWorkItem { [weak self] in
            Task { await self?.fetchPosts() }
        }

        loadMoreWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: item)
    }

    @MainActor
    func followUser(userID: String) async {
        let params: [String: Any] = [
            "user_id": userID
        ]
        
        do {
            let _: BaseActionResponse = try await APIManager.shared.request(
                url: APIList.followUser,
                parameters: params,
                model: BaseActionResponse.self
            )
            print("✅ Followed user \(userID)")
            // Update local list to reflect change (optimistic update)
            if let index = followersList.firstIndex(where: { $0.user_id == userID }) {
                followersList[index].is_following = 1
            }
            if let index = followingList.firstIndex(where: { $0.user_id == userID }) {
                followingList[index].is_following = 1
            }
        } catch {
            print("❌ Error following user:", error.localizedDescription)
        }
    }


}

struct BaseActionResponse: Mappable {
    var api_status: Int?
    var action: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        api_status <- map["api_status"]
        action <- map["action"]
    }
}
