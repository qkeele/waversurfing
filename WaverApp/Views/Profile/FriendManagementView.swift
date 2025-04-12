//
//  FriendManagementView.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import SwiftUI

struct FriendManagementView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var service = FriendsService()
    @State private var incomingRequests: [WaverUser] = []
    @State private var acceptedFriends: [WaverUser] = []
    @State private var selectedFriend: WaverUser?
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔹 Top Bar
                HStack {
                    Text("Friends")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.4)
                    Spacer()
                } else if incomingRequests.isEmpty && acceptedFriends.isEmpty {
                    Spacer()
                    Text("No friends or requests yet")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        // 🔸 Incoming requests
                        ForEach(incomingRequests, id: \.id) { user in
                            RequestRow(
                                user: user,
                                onAccept: {
                                    try? await service.acceptFriendRequest(myId: userSession.currentUser!.id, otherId: user.id)
                                    acceptedFriends.insert(user, at: 0)
                                    incomingRequests.removeAll { $0.id == user.id }
                                },
                                onReject: {
                                    try? await service.cancelFriendRequest(myId: user.id, otherUserId: userSession.currentUser!.id)
                                    incomingRequests.removeAll { $0.id == user.id }
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }

                        // 🔸 Accepted friends
                        ForEach(acceptedFriends, id: \.id) { user in
                            Button {
                                selectedFriend = user
                            } label: {
                                HStack {
                                    Text(user.username)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .task {
                await loadData()
            }
            .sheet(item: $selectedFriend) { friend in
                UserProfileView(user: friend)
            }
        }
    }

    private func loadData() async {
        guard let myId = userSession.currentUser?.id else { return }
        isLoading = true
        incomingRequests = await (try? service.getIncomingFriendRequests(for: myId)) ?? []
        acceptedFriends = await (try? service.getAcceptedFriends(for: myId)) ?? []
        isLoading = false
    }
}

