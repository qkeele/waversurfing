//
//  SearchResultsViewModel.swift
//  Waver
//
//  Created by Quincy Keele on 4/8/25.
//

import Foundation
import Combine
import Supabase

final class SearchResultsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var spotResults: [Spot] = []
    @Published var userResults: [WaverUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let client = SupabaseService.shared.client

    var searchType: SearchType = .spots {
        didSet { search(term: searchText) }
    }

    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] term in
                self?.search(term: term)
            }
            .store(in: &cancellables)
    }

    func search(term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            spotResults = []
            userResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                switch searchType {
                case .spots:
                    let spots = try await self.searchSpots(term: trimmed)
                    await MainActor.run {
                        self.spotResults = spots
                        self.userResults = []
                        self.isLoading = false
                    }
                case .people:
                    let users = try await self.searchUsers(term: trimmed)
                    await MainActor.run {
                        self.userResults = users
                        self.spotResults = []
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.spotResults = []
                    self.userResults = []
                    self.isLoading = false
                }
            }
        }
    }

    private func searchSpots(term: String) async throws -> [Spot] {
        let response = try await client
            .from("spots")
            .select("id, name, region, sub_region, sub_sub_region")
            .filter("name", operator: "ilike", value: "%\(term)%")
            .execute()

        return try JSONDecoder().decode([Spot].self, from: response.data)
    }

    private func searchUsers(term: String) async throws -> [WaverUser] {
        let response = try await client
            .from("users")
            .select("id, auth_id, username, email, timestamp")
            .filter("username", operator: "ilike", value: "%\(term)%")
            .execute()

        return try WaverUser.decoder.decode([WaverUser].self, from: response.data)
    }
}
