//
//  NewsFeedViewModel.swift
//  PunjabAppNew
//
//  Created by pc on 14/11/25.
//

import Foundation

@MainActor
final class NewsFeedViewModel: ObservableObject {

    @Published var posts: [Post] = []
//    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var isLoadingStories = false
    @Published var hasMorePosts = true

    // API Call: Fetch Posts
    func getNewsFeed() async {

        guard hasMorePosts else { return }
        guard !isLoading else { return }
        isLoading = true

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
            let result: FeedModel = try await APIManager.shared.request(
                url: APIList.posts,
                parameters: params,
                model: FeedModel.self
            )


            if result.api_status == 200 {
                if let newPosts = result.data, !newPosts.isEmpty {
                    posts.append(contentsOf: newPosts)
                } else {
                    hasMorePosts = false
                }
            }

        } catch {
            print("❌ Error fetching posts:", error.localizedDescription)
        }

        isLoading = false
    }

//    // API Call: Fetch Stories
//    func getStories() async {
//
//        guard !isLoadingStories else { return }
//        isLoadingStories = true
//
//        let userID = UserDefaults.getUserID()
//
//        var params: [String: Any] = [
//            "type": "get_news_feed",
//            "user_id": userID,
//            "limit": "10"
//        ]
//
//        if let lastID = posts.last?.id {
//            params["after_post_id"] = lastID
//        }
//
//        do {
//            let result: storyModel = try await APIManager.shared.requestAsync(
//                url: APIList.stories,
//                method: .post,
//                parameters: params
//            )
//
//            if result.api_status == 200 {
//                stories.append(contentsOf: result.stories ?? [])
//            }
//
//        } catch {
//            print("❌ Error fetching stories:", error.localizedDescription)
//        }
//
//        isLoadingStories = false
//    }
}
