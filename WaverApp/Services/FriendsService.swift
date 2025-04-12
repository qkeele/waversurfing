//
//  FriendsService.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import Supabase
import Foundation

enum FriendshipStatus {
    case notFriends
    case requestSent
    case requestReceived
    case friends
}

final class FriendsService: ObservableObject {
    private let client = SupabaseService.shared.client

    func checkFriendshipStatus(myId: UUID, otherId: UUID) async throws -> FriendshipStatus {
        let response = try await client
            .from("friends")
            .select("requester_id, receiver_id, status")
            .or("and(requester_id.eq.\(myId),receiver_id.eq.\(otherId)),and(requester_id.eq.\(otherId),receiver_id.eq.\(myId))")
            .limit(1)
            .execute()

        guard let array = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
              let row = array.first,
              let status = row["status"] as? String,
              let requesterStr = row["requester_id"] as? String,
              let requester = UUID(uuidString: requesterStr) else {
            return .notFriends
        }

        if status == "accepted" {
            return .friends
        } else if status == "pending" {
            return requester == myId ? .requestSent : .requestReceived
        } else {
            return .notFriends
        }
    }

    func sendFriendRequest(myId: UUID, otherId: UUID) async throws {
        let insert = [
            "requester_id": myId.uuidString,
            "receiver_id": otherId.uuidString,
            "status": "pending"
        ]
        try await client.from("friends").insert([insert]).execute()
    }

    func acceptFriendRequest(myId: UUID, otherId: UUID) async throws {
        try await client
            .from("friends")
            .update(["status": "accepted"])
            .match([
                "requester_id": otherId.uuidString,
                "receiver_id": myId.uuidString,
                "status": "pending"
            ])
            .execute()
    }

    func cancelFriendRequest(myId: UUID, otherUserId: UUID) async throws {
        try await client
            .from("friends")
            .delete()
            .match([
                "requester_id": myId.uuidString,
                "receiver_id": otherUserId.uuidString,
                "status": "pending"
            ])
            .execute()
    }

    func removeFriend(myId: UUID, otherUserId: UUID) async throws {
        try await client
            .from("friends")
            .delete()
            .or("and(requester_id.eq.\(myId),receiver_id.eq.\(otherUserId)),and(requester_id.eq.\(otherUserId),receiver_id.eq.\(myId))")
            .filter("status", operator: "eq", value: "accepted")
            .execute()
    }
    
    func getIncomingFriendRequests(for userId: UUID) async throws -> [WaverUser] {
        let response = try await client
            .rpc("get_incoming_requests", params: ["user_id": userId.uuidString])
            .execute()

        return try WaverUser.decoder.decode([WaverUser].self, from: response.data)
    }

    func getAcceptedFriends(for userId: UUID) async throws -> [WaverUser] {
        let response = try await client
            .rpc("get_accepted_friends", params: ["user_id": userId.uuidString])
            .execute()

        return try WaverUser.decoder.decode([WaverUser].self, from: response.data)
    }

}
