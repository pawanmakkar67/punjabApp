//
//  RootView.swift
//  FacebookClone
//
//  Created by omar thamri on 8/1/2024.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
        var body: some View {
            Group {
                if appState.isLoggedIn {
                    MainTabbarView()   // 👈 Show Home
                } else {
                    LoginView()  // 👈 Show Onboarding/Login/Register
                }

            }
        }
}

#Preview {
    RootView()
}
