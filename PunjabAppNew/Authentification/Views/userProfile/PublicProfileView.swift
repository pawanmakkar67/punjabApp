//
//  PublicProfileView.swift
//  PunjabAppNew
//
//  Created by pc on 22/01/2026.
//

import SwiftUI

struct PublicProfileView: View {
    let user: User_data
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Custom Public Profile Header
                PublicProfileHeader(user: user)
                
                // Action Buttons for Public Profile
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Follow")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        Text("Friends")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                ProfileMediaSelectionView(viewModel: viewModel, userID: user.user_id)
                
            }
        }
        .navigationTitle(user.displayName ?? "Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
