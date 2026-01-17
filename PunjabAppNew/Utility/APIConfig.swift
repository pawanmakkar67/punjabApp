//
//  APIConfig.swift
//  PunjabAppNew
//
//  Created by pc on 03/11/25.
//


import Foundation

// MARK: - API Configuration
enum APIConfig {
    static let serverKey = "3ae76dd05d8502d14bc94094a5eeea16"

    #if DEBUG
    static let baseURL = "https://stage.ludhianalive.com/"
    static let baseAPI = "https://stage.ludhianalive.com/api/"
    #else
    static let baseURL = "https://ludhianalive.com/"
    static let baseAPI = "https://ludhianalive.com/api/"
    #endif
}


enum APIList {
    static let checkUserExists     = APIConfig.baseAPI + "auth/me"
    static let login               = APIConfig.baseAPI + "auth"
    static let register            = APIConfig.baseAPI + "create-account"
    static let verifyOTP           = APIConfig.baseAPI + "active_account_sms"
    static let resendOTP           = APIConfig.baseAPI + "resend-verification-code"
    static let getUserDetails      = APIConfig.baseAPI + "get-user-data"
    static let generalData         = APIConfig.baseAPI + "get-general-data"
    static let sendFriendRequest   = APIConfig.baseAPI + "get-friends"
    static let nearbyFriendRequest = APIConfig.baseAPI + "fetch-recommended"
    static let posts               = APIConfig.baseAPI + "posts"
    static let reaction            = APIConfig.baseAPI + "post-actions"
    static let stories             = APIConfig.baseAPI + "get-user-stories-new"
    static let search              = APIConfig.baseAPI + "search"
    static let getFilteredPosts    = APIConfig.baseAPI + "get-filtered-posts"
    static let createStory         = APIConfig.baseAPI + "create-story"
    static let comments         = APIConfig.baseAPI + "comments"
    static let new_post               = APIConfig.baseAPI + "new_post"
    static let getReels               = APIConfig.baseAPI + "get-reels"
    static let followUser             = APIConfig.baseAPI + "follow-user"

    
    
}


extension APIList {
    static func endpoint(_ path: String) -> String {
        return APIConfig.baseAPI + path
    }
}
