//
//  SearchViewModel.swift
//  PunjabAppNew
//
//  Created by pc on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine
import ObjectMapper

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [User_data] = []
    @Published var isLoading = false
    @Published var hasSearched = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    
    init() {
        // Debounce search text changes
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchKey in
                guard let self = self else { return }
                if searchKey.isEmpty {
                    Task { @MainActor in
                        self.clearSearch()
                    }
                } else {
                    Task {
                        await self.performSearch(searchKey: searchKey)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func performSearch(searchKey: String) async {
        // Cancel previous search task
        searchTask?.cancel()
        
        guard !searchKey.isEmpty else {
            clearSearch()
            return
        }
        
        isLoading = true
        errorMessage = nil
        hasSearched = true
        
        let userID = UserDefaults.getUserID() ?? ""
        
        let params: [String: Any] = [
            "search_key": searchKey,
            "user_id": userID,
            "limit": "20",
            "offset": "0"
        ]
        
        searchTask = Task {
            do {
                // Move API call off main thread
                let result: SearchModel = try await withCheckedThrowingContinuation { continuation in
                    Task.detached {
                        do {
                            let res: SearchModel = try await APIManager.shared.request(
                                url: APIList.search,
                                parameters: params,
                                model: SearchModel.self
                            )
                            continuation.resume(returning: res)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                if result.api_status == 200 {
                    await MainActor.run {
                        // Convert Users to User_data
                        self.searchResults = self.convertUsersToUserData(result.users ?? [])
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Search failed"
                        self.isLoading = false
                    }
                }
                
            } catch {
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                print("❌ Error searching:", error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func clearSearch() {
        searchTask?.cancel()
        searchResults = []
        hasSearched = false
        errorMessage = nil
        isLoading = false
    }
    
    // Helper function to convert Users to User_data
    private func convertUsersToUserData(_ users: [Users]) -> [User_data] {
        return users.compactMap { user in
            var userData = User_data(map: Map(mappingType: .fromJSON, JSON: [:]))
            userData?.user_id = user.user_id
            userData?.username = user.username
            userData?.email = user.email
            userData?.first_name = user.first_name
            userData?.last_name = user.last_name
            userData?.avatar = user.avatar
            userData?.cover = user.cover
            userData?.is_verified = user.is_verified
            userData?.is_following = user.is_following
            userData?.is_following_me = user.is_following_me
            userData?.about = user.about
            userData?.avatar_full = user.avatar_full
            return userData
        }
    }
}
