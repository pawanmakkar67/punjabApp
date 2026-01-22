//
//  PagesView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI

struct PagesView: View {
    // Mock Data for the design
    @State private var pages: [PageModel] = [
        PageModel(name: "Developers", likes: 1, category: "Science and Technology"),
        PageModel(name: "Tech Fun", likes: 0, category: "Science and Technology"),
        PageModel(name: "KP JOKES", likes: 0, category: "Comedy"),
        PageModel(name: "drawings", likes: 0, category: "Cars and Vehicles"),
        PageModel(name: "fun jokes", likes: 1, category: "Comedy") // Added for My Pages demo
    ]
    
    @State private var selectedFilter: PageFilter = .discover
    
    enum PageFilter: String, CaseIterable {
        case discover = "Discover"
        case invitation = "Invitation"
        case likedPages = "Liked Pages"
        case createPage = "Create Page"
        case myPages = "My Pages"
        
        var iconName: String {
            switch self {
            case .discover: return "safari"
            case .invitation: return "person.fill"
            case .likedPages: return "hand.thumbsup.fill"
            case .createPage: return "plus.circle.fill"
            case .myPages: return "flag.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Filter Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(title: PageFilter.discover.rawValue, iconName: PageFilter.discover.iconName, isSelected: selectedFilter == .discover) {
                            selectedFilter = .discover
                        }
                        
                        FilterChip(title: PageFilter.invitation.rawValue, iconName: PageFilter.invitation.iconName, isSelected: selectedFilter == .invitation) {
                            selectedFilter = .invitation
                        }
                        
                        FilterChip(title: PageFilter.likedPages.rawValue, iconName: PageFilter.likedPages.iconName, isSelected: selectedFilter == .likedPages) {
                            selectedFilter = .likedPages
                        }
                        
                        FilterChip(title: PageFilter.createPage.rawValue, iconName: PageFilter.createPage.iconName, isSelected: selectedFilter == .createPage) {
                            selectedFilter = .createPage
                        }
                        
                        FilterChip(title: PageFilter.myPages.rawValue, iconName: PageFilter.myPages.iconName, isSelected: selectedFilter == .myPages) { 
                            selectedFilter = .myPages
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                Divider()
                
                // Content
                if selectedFilter == .createPage {
                    CreatePageView()
                } else {
                    // Pages List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(pages) { page in
                                PageRowView(
                                    page: page,
                                    isInvitation: selectedFilter == .invitation,
                                    isMyPage: selectedFilter == .myPages
                                )
                                Divider()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Models
struct PageModel: Identifiable {
    let id = UUID()
    let name: String
    let likes: Int
    let category: String
}

// MARK: - Subviews

struct FilterChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !iconName.isEmpty {
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(isSelected ? Color(hex: "#58102C") : .primary)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color(hex: "#58102C") : Color(.systemGray4), lineWidth: 1)
                    .background(Color.white.cornerRadius(20))
            )
        }
    }
}

struct PageRowView: View {
    let page: PageModel
    let isInvitation: Bool
    let isMyPage: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Flag Icon with Overlay for Invitation
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFF0E0")) // Light peach background
                        .frame(width: 60, height: 60)
                    
                    if isMyPage && page.name == "fun jokes" {
                        // Mocking the specific image look for the demo if possible, otherwise standard flag
                        // For now using the standard flag but maybe different color could imply "My Page" uniqueness
                        Image(systemName: "gift.fill") // Using gift to match the 'fun jokes' icon roughly
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "flag.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(hex: "#FF8C60")) // Orange flag color
                    }
                }
                
                if isInvitation {
                    Circle()
                        .fill(Color(hex: "#58102C"))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "hand.thumbsup.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .foregroundColor(.white)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(page.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                if isMyPage {
                    Text(page.category)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(page.likes) People Liked This")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    // No buttons for My Pages
                } else if !isInvitation {
                    Text("\(page.likes) People Liked This")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text(page.category)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                if isInvitation {
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Accept")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(hex: "#58102C"))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {}) {
                            Text("Reject")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 8)
                } else if !isMyPage {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "hand.thumbsup.fill")
                            Text("Like")
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#58102C")) // Burgundy/Dark Red
                        .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer() 
        }
        .padding()
    }
}



#Preview {
    PagesView()
}
