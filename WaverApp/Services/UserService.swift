//
//  UserService.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation
import Supabase

class UserService: ObservableObject {
    static let shared = UserService()
    
    private let client = SupabaseService.shared.client
    
    func fetchUsername(for userId: UUID) async -> String? {
        do {
            let responseData = try await SupabaseService.shared.client
                .from("users")
                .select("username")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .data

            let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
            return json?["username"] as? String
        } catch {
            print("Error fetching username: \(error)")
            return nil
        }
    }
    
    func fetchUser(byId userId: UUID) async -> WaverUser? {
        do {
            let response = try await client
                .from("users")
                .select("id, username")
                .eq("id", value: userId.uuidString)
                .single()
                .execute()

            let user = try JSONDecoder().decode(WaverUser.self, from: response.data)
            return user
        } catch {
            print("Error fetching user object: \(error)")
            return nil
        }
    }

    func requestAccountDeletion(userId: UUID) async {
        do {
            try await SupabaseService.shared.client
                .from("deletion_requests")
                .insert(["user_id": userId])
                .execute()
            print("Deletion request logged for user \(userId)")
        } catch {
            print("Error logging deletion request: \(error)")
        }
    }
}
