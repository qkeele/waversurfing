//
//  UserProfileViewLoader.swift
//  Waver
//
//  Created by Sydney Del Fosse on 5/8/25.
//

import SwiftUI

struct UserProfileViewLoader: View {
    let userId: UUID
    @State private var user: WaverUser?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let user = user {
                UserProfileView(user: user)
            } else if isLoading {
                ProgressView()
            } else {
                Text("Failed to load user")
            }
        }
        .task {
            if user == nil {
                user = await UserService().fetchUser(byId: userId)
                isLoading = false
            }
        }
    }
}
