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

    var isResetEnabled: Bool {
        !resetEmail.isEmpty && !isLoading
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Image("waver_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)

                Text("Reset Password")
                    .font(.title2)
                    .bold()

                Text("Enter your email to receive a password reset link.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                TextField("Email", text: $resetEmail)
                    .tint(.white)
                    .foregroundColor(.white)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))
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
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(isResetEnabled ? .white : .white.opacity(0.2))
                .foregroundColor(isResetEnabled ? .black : .gray)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .disabled(!isResetEnabled)
            }

            // **Toast Notification - Now Positioned at the Very Top**
            VStack {
                if toastManager.isShowing {
                    ToastView(message: toastManager.message, backgroundColor: toastManager.color)
                        .frame(maxWidth: .infinity) // Make it full width
                        .padding(.top, 50) // Push it to the top
                        .transition(.move(edge: .top).combined(with: .opacity)) // Proper slide animation
                        .zIndex(2)
                }
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}
