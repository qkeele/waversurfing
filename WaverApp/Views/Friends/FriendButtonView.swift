//
//  FriendButtonView.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import Foundation
import SwiftUI

struct FriendButtonView: View {
    let myUserId: UUID
    let otherUserId: UUID
    let toastManager: ToastManager // ✅ passed in directly

    @StateObject private var vm = FriendButtonViewModel()
    @State private var showUnfriendConfirm = false

    var body: some View {
        Button {
            switch vm.friendshipStatus {
            case .notFriends, .requestReceived:
                Task {
                    await vm.handleAddOrAccept(myId: myUserId, otherId: otherUserId, toastManager: toastManager)
                }

            case .requestSent:
                Task {
                    await vm.handleCancel(myId: myUserId, otherId: otherUserId, toastManager: toastManager)
                }

            case .friends:
                showUnfriendConfirm = true
            }
        } label: {
            Image(systemName: vm.iconName)
                .font(.title2)
                .foregroundColor(vm.iconColor)
        }
        .confirmationDialog("Remove Friend?", isPresented: $showUnfriendConfirm) {
            Button("Remove", role: .destructive) {
                Task {
                    await vm.handleRemove(myId: myUserId, otherId: otherUserId, toastManager: toastManager)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            Task {
                await vm.loadStatus(myId: myUserId, otherId: otherUserId)
            }
        }
    }
}

