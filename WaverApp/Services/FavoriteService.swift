//
//  FavoriteService.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation
import Supabase

class FavoriteService: ObservableObject {
    private let client = SupabaseService.shared.client

    // Create a new favorite (link user & spot)
    func addFavorite(_ favorite: Favorite) async throws {
        try await client
            .from("favorites")
            .insert(favorite)
            .execute()
    }

    // Fetch all favorites for a user
    func fetchFavorites(forUserId userId: UUID) async throws -> [Favorite] {
        try await client
            .from("favorites")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
    }

    // Check if a user has favorited a spot
    func isSpotFavorited(byUserId userId: UUID, spotId: UUID) async throws -> Bool {
        let favorites: [Favorite] = try await client
            .from("favorites")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("spot_id", value: spotId.uuidString)
            .limit(1)
            .execute()
            .value
        return !favorites.isEmpty
    }

    // Remove a favorite (unfavorite a spot)
    func removeFavorite(userId: UUID, spotId: UUID) async throws {
        try await client
            .from("favorites")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("spot_id", value: spotId.uuidString)
            .execute()
    }
    
    func toggleFavorite(userId: UUID, spotId: UUID) async throws -> Bool {
            if try await isSpotFavorited(byUserId: userId, spotId: spotId) {
                try await removeFavorite(userId: userId, spotId: spotId)
                return false // Unfavorited
            } else {
                let favorite = Favorite(id: UUID(), user_id: userId, spot_id: spotId)
                try await addFavorite(favorite)
                return true // Favorited
            }
        }
}
