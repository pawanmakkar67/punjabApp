//
//  AppState.swift
//  PunjabAppNew
//
//  Created by pc on 14/11/25.
//

import Foundation


@MainActor
final class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    init() {
        // Check if user is already stored
        isLoggedIn = UserDefaults.standard.string(forKey: UserDefaults.Keys.userId)?.isEmpty == false
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.userId)
        isLoggedIn = false
    }

    func login() {
        isLoggedIn = true
    }
}
