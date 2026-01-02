//
//  Keys.swift
//  PunjabAppNew
//
//  Created by pc on 03/11/25.
//


import Foundation

extension UserDefaults {
    enum Keys {
        static let accessToken = "access_token"
        static let userId = "user_id"
        static let userToken = "user_Token"
        static let currentUser = "current_User"
        static let currentUserLastUpdated = "currentUserLastUpdated"
    }

    // MARK: - Setters
    static func setDeviceToken(token: String) {
        UserDefaults.standard.set(token, forKey: Keys.accessToken)
    }

    static func setUserID(token: String) {
        UserDefaults.standard.set(token, forKey: Keys.userId)
    }

    // MARK: - Getters
    static func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.accessToken)
    }

    static func getUserID() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userId)
    }

    static func setUserToken(token:String) {
        standard.set(token, forKey: Keys.userToken)
    }
    
    
    static func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: Keys.userToken)
    }

    
    func saveUser(_ user: User_data?) {
        guard let user = user,
              let jsonString = user.toJSONString() else { return }
        set(Date().timeIntervalSince1970, forKey: Keys.currentUserLastUpdated)
        set(jsonString, forKey: Keys.currentUser)
    }

    func loadUser() -> User_data? {
        guard let jsonString = string(forKey: Keys.currentUser) else { return nil }
        return User_data(JSONString: jsonString)
    }

    // MARK: - Check if cache expired (24 hours)
     func isUserCacheExpired() -> Bool {
         let lastUpdated = double(forKey: Keys.currentUserLastUpdated)
         if lastUpdated == 0 { return true }

         let now = Date().timeIntervalSince1970
         let hoursPassed = (now - lastUpdated) / 3600
         
         return hoursPassed >= 24
     }
    
    // MARK: - Utility
    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.userId)
    }
}
