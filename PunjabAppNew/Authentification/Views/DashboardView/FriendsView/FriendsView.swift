//
//  ContentView.swift
//  FacebookClone
//
//  Created by omar thamri on 26/12/2023.
//

import SwiftUI
import ObjectMapper
import Kingfisher
//search_key
struct FriendsView: View {
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var selectedTab: Int = 0
    @State private var searchText: String = "" // Search text
    @State private var isSearchActive: Bool = false // Search mode toggle
    @State private var pendingRequests: [User_data] = [] // Pending friend requests
    @State private var sentRequests: [User_data] = [] // Sent friend requests
    @State private var nearbyFriends: [User_data] = [] // Nearby friends
    
    // Computed properties for filtered data
    var filteredPendingRequests: [User_data] {
        if searchText.isEmpty {
            return pendingRequests
        }
        return pendingRequests.filter { user in
            let fullName = "\(user.first_name ?? "") \(user.last_name ?? "")".lowercased()
            let username = (user.username ?? "").lowercased()
            return fullName.contains(searchText.lowercased()) || username.contains(searchText.lowercased())
        }
    }
    
    var filteredSentRequests: [User_data] {
        if searchText.isEmpty {
            return sentRequests
        }
        return sentRequests.filter { user in
            let fullName = "\(user.first_name ?? "") \(user.last_name ?? "")".lowercased()
            let username = (user.username ?? "").lowercased()
            return fullName.contains(searchText.lowercased()) || username.contains(searchText.lowercased())
        }
    }
    
    var filteredNearbyFriends: [User_data] {
        if searchText.isEmpty {
            return nearbyFriends
        }
        return nearbyFriends.filter { user in
            let fullName = "\(user.first_name ?? "") \(user.last_name ?? "")".lowercased()
            let username = (user.username ?? "").lowercased()
            return fullName.contains(searchText.lowercased()) || username.contains(searchText.lowercased())
        }
    }
    
    var filteredFriends: [User] {
        guard let friends = viewModel.friends else { return [] }
        if searchText.isEmpty {
            return friends
        }
        return friends.filter { friend in
            let fullName = "\(friend.firstName ?? "") \(friend.familyName ?? "")".lowercased()
            return fullName.contains(searchText.lowercased())
        }
    }
    
    // Combined search results from all sources
    var allSearchResults: [User_data] {
        var results: [User_data] = []
        results.append(contentsOf: filteredPendingRequests)
        results.append(contentsOf: filteredSentRequests)
        results.append(contentsOf: filteredNearbyFriends)
        return results
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar (only shown when search is active)
                if isSearchActive {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search friends", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Custom Segmented Control with 4 tabs (hidden when search is active)
                if !isSearchActive {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            TabButton(title: "Pending", isSelected: selectedTab == 0) {
                                withAnimation { selectedTab = 0 }
                            }
                            
                            TabButton(title: "Sent", isSelected: selectedTab == 1) {
                                withAnimation { selectedTab = 1 }
                            }
                            
                            TabButton(title: "Nearby", isSelected: selectedTab == 2) {
                                withAnimation { selectedTab = 2 }
                            }
                            
                            TabButton(title: "Friends", isSelected: selectedTab == 3) {
                                withAnimation { selectedTab = 3 }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    Divider()
                }
                
                // Show search results or tabs based on search mode
                if isSearchActive {
                    // Search Results View
                    if searchViewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Searching...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !searchViewModel.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(searchViewModel.searchResults, id: \.user_id) { user in
                                    SearchResultRow(user: user)
                                }
                            }
                            .padding()
                        }
                    } else if searchViewModel.hasSearched {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No results found")
                                .font(.headline)
                            Text("Try searching with different keywords")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue.opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text("Search for People")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Find friends and new connections")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    // Normal Tab View
                    TabView(selection: $selectedTab) {
                    // Pending Requests Tab
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if filteredPendingRequests.isEmpty {
                                EmptyStateView(
                                    icon: "person.crop.circle.badge.plus",
                                    message: searchText.isEmpty ? "No pending friend requests" : "No results found"
                                )
                            } else {
                                ForEach(filteredPendingRequests, id: \.user_id) { user in
                                    FriendRequestRow(user: user, onConfirm: {
                                        confirmRequest(user)
                                    }, onDelete: {
                                        deleteRequest(user)
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // Sent Requests Tab
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if filteredSentRequests.isEmpty {
                                EmptyStateView(
                                    icon: "paperplane.circle.fill",
                                    message: searchText.isEmpty ? "No sent friend requests" : "No results found"
                                )
                            } else {
                                ForEach(filteredSentRequests, id: \.user_id) { user in
                                    SentRequestRow(user: user, onCancel: {
                                        cancelSentRequest(user)
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    // Nearby Friends Tab
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if filteredNearbyFriends.isEmpty {
                                EmptyStateView(
                                    icon: "location.circle.fill",
                                    message: searchText.isEmpty ? "No nearby friends found" : "No results found"
                                )
                            } else {
                                ForEach(filteredNearbyFriends, id: \.user_id) { user in
                                    NearbyFriendRow(user: user, onAddFriend: {
                                        sendFriendRequest(user)
                                    })
                                }
                            }
                        }
                        .padding()
                    }
                    .tag(2)
                    
                    // Your Friends Tab
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if !filteredFriends.isEmpty {
                                ForEach(filteredFriends) { friend in
                                    FriendRow(friend: friend)
                                }
                            } else {
                                EmptyStateView(
                                    icon: "person.2.fill",
                                    message: searchText.isEmpty ? "No friends yet" : "No results found"
                                )
                            }
                        }
                        .padding()
                    }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .dismissKeyboardOnTap()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isSearchActive.toggle()
                            if !isSearchActive {
                                searchText = ""
                                searchViewModel.searchText = ""
                                searchViewModel.searchResults = []
                                searchViewModel.hasSearched = false
                            }
                        }
                    }) {
                        if isSearchActive {
                            Text("Cancel")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                if isSearchActive && !newValue.isEmpty {
                    Task {
                        await searchViewModel.performSearch(searchKey: newValue)
                    }
                }
            }
            .onAppear {
                loadMockData()
            }
        }
    }
    
    
    @MainActor
    private func fetchNearbyFriends() async {
        let userID = UserDefaults.getUserID() ?? ""
        
        let params: [String: Any] = [
            "fetch": "nearby_friends",
            "type": "users",
            "limit": "50"
        ]
        
        do {
            let result: NearbyModel = try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        let res: NearbyModel = try await APIManager.shared.request(
                            url: APIList.nearbyFriendRequest,
                            parameters: params,
                            model: NearbyModel.self
                        )
                        continuation.resume(returning: res)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if result.api_status == 200 {
                if let users = result.data, !users.isEmpty {
                    await MainActor.run {
                        nearbyFriends = users
                    }
                }
            }
        } catch {
            print("❌ Error fetching nearby friends:", error.localizedDescription)
        }
    }
    
    private func loadMockData() {
        // Simulate fetching pending requests
        var mockUser1 = User_data(map: Map(mappingType: .fromJSON, JSON: [:]))
        mockUser1?.first_name = "John"
        mockUser1?.last_name = "Doe"
        mockUser1?.username = "johndoe"
        mockUser1?.user_id = "mock_1"
        
        var mockUser2 = User_data(map: Map(mappingType: .fromJSON, JSON: [:]))
        mockUser2?.first_name = "Jane"
        mockUser2?.last_name = "Smith"
        mockUser2?.username = "janesmith"
        mockUser2?.user_id = "mock_2"
        
        if let user1 = mockUser1, let user2 = mockUser2 {
            pendingRequests = [user1]
            sentRequests = [user2]
        }
        
        // Fetch nearby friends from API
        Task {
            await fetchNearbyFriends()
        }
    }
    
    private func confirmRequest(_ user: User_data) {
        withAnimation {
            pendingRequests.removeAll(where: { $0.user_id == user.user_id })
            // Add to friends logic here
        }
    }
    
    private func deleteRequest(_ user: User_data) {
        withAnimation {
            pendingRequests.removeAll(where: { $0.user_id == user.user_id })
        }
    }
    
    private func cancelSentRequest(_ user: User_data) {
        withAnimation {
            sentRequests.removeAll(where: { $0.user_id == user.user_id })
        }
    }
    
    private func sendFriendRequest(_ user: User_data) {
        withAnimation {
            nearbyFriends.removeAll(where: { $0.user_id == user.user_id })
            sentRequests.append(user)
        }
    }
}

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 50)
    }
}

struct FriendRequestRow: View {
    let user: User_data
    let onConfirm: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill") // Placeholder
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Button(action: onConfirm) {
                        Text("Confirm")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        Text("Delete")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()
        }
    }
}

// MARK: - Sent Request Row
struct SentRequestRow: View {
    let user: User_data
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill") // Placeholder
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                Text("Request sent")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Nearby Friend Row
struct NearbyFriendRow: View {
    let user: User_data
    let onAddFriend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill") // Placeholder
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Nearby")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: onAddFriend) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
}


struct FriendRow: View {
    let friend: User
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: friend.profileImageName ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(friend.displayName)
                    .font(.headline)
            }
            Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    FriendsView()
}





