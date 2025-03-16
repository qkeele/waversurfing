//
//  ResetPasswordView.swift
//  Waver
//
//  Created by Quincy Keele on 2/23/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var resetEmail = ""
    @State private var isLoading = false
    @StateObject private var toastManager = ToastManager()

    @Environment(\.colorScheme) var colorScheme

    var isResetEnabled: Bool {
        !resetEmail.isEmpty && !isLoading
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image(colorScheme == .dark ? "waver_logo" : "waver_logo_black")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)

                Text("Reset Password")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.primary)

                Text("Enter your email to receive a password reset link.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                TextField("Email", text: $resetEmail)
                    .tint(Color.primary)
                    .foregroundColor(Color.primary)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary, lineWidth: 1))
                    .padding(.horizontal, 20)

                Spacer()

                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            try await SupabaseService.shared.sendPasswordReset(email: resetEmail)
                            toastManager.showToast(message: "Password reset link sent!", color: .green)
                        } catch {
                            toastManager.showToast(message: "Failed to send reset email", color: .red)
                        }
                        isLoading = false
                    }
                }) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(.systemBackground)))
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(isResetEnabled ? Color.primary : Color.secondary.opacity(0.2))
                .foregroundColor(isResetEnabled ? Color(.systemBackground) : .gray)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .disabled(!isResetEnabled)
            }

            VStack {
                if toastManager.isShowing {
                    ToastView(message: toastManager.message, backgroundColor: toastManager.color)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                }
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}
