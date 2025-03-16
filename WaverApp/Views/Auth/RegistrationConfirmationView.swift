//
//  RegistrationConfirmationView.swift
//  Waver
//
//  Created by Quincy Keele on 2/26/25.
//

import SwiftUI

struct RegistrationConfirmationView: View {
    var didDismiss: () -> Void
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.green)

                Text("Signed up successfully.")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.primary)

                Text("Verify your email before logging in.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Spacer()
            }
        }
        .onDisappear {
            didDismiss()
        }
    }
}
