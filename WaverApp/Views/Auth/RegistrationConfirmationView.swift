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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with X button in the top-right corner
                HStack {
                    Spacer()

                    Button {
                        // Close this view, then notify parent
                        dismiss()
                        didDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    .padding([.top, .trailing])
                }

                Spacer()

                VStack(spacing: 20) {
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
                }

                Spacer()
            }
        }
    }
}
