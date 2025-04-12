//
//  RequestRow.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import SwiftUI

struct RequestRow: View {
    let user: WaverUser
    let onAccept: () async -> Void
    let onReject: () async -> Void

    @State private var isHandled = false

    var body: some View {
        HStack {
            Text(user.username)
            Spacer()

            if isHandled {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            } else {
                Button("Accept") {
                    Task {
                        await onAccept()
                        isHandled = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                Button("Decline") {
                    Task {
                        await onReject()
                    }
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .animation(.easeInOut, value: isHandled)
    }
}
