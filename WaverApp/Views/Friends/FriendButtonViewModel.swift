//
//  FriendButtonViewModel.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import Foundation
import SwiftUI

@MainActor
final class FriendButtonViewModel: ObservableObject {
    @Published var friendshipStatus: FriendshipStatus = .notFriends
    private let service = FriendsService()

    var iconName: String {
        switch friendshipStatus {
        case .notFriends, .requestReceived: return "plus.circle"
        case .requestSent: return "plus.circle"
        case .friends: return "checkmark.circle"
        }
    }

    var iconColor: Color {
        switch friendshipStatus {
        case .friends, .notFriends, .requestReceived: return .primary
        case .requestSent: return .gray
        }
    }

    func loadStatus(myId: UUID, otherId: UUID) async {
        do {
            friendshipStatus = try await service.checkFriendshipStatus(myId: myId, otherId: otherId)
        } catch {
            friendshipStatus = .notFriends
        }
    }

    func handleAddOrAccept(myId: UUID, otherId: UUID, toastManager: ToastManager) async {
        do {
            if friendshipStatus == .requestReceived {
                try await service.acceptFriendRequest(myId: myId, otherId: otherId)
                friendshipStatus = .friends
                toastManager.showToast(message: "Friend accepted", color: .green)
            } else {
                try await service.sendFriendRequest(myId: myId, otherId: otherId)
                friendshipStatus = .requestSent
                toastManager.showToast(message: "Request sent", color: .green)
            }
        } catch {
            toastManager.showToast(message: "Error: \(error.localizedDescription)", color: .red)
        }
    }

    func handleCancel(myId: UUID, otherId: UUID, toastManager: ToastManager) async {
        do {
            try await service.cancelFriendRequest(myId: myId, otherUserId: otherId)
            friendshipStatus = .notFriends
            toastManager.showToast(message: "Request canceled", color: .green)
        } catch {
            toastManager.showToast(message: "Error: \(error.localizedDescription)", color: .red)
        }
    }

    func handleRemove(myId: UUID, otherId: UUID, toastManager: ToastManager) async {
        do {
            try await service.removeFriend(myId: myId, otherUserId: otherId)
            friendshipStatus = .notFriends
            toastManager.showToast(message: "Friend removed", color: .green)
        } catch {
            toastManager.showToast(message: "Error: \(error.localizedDescription)", color: .red)
        }
    }
}
