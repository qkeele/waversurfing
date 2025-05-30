//
//  SignInView.swift
//  Waver
//
//  Created by Quincy Keele on 2/17/25.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingReset = false
    @Binding var isRegistering: Bool

    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    @EnvironmentObject var userSession: UserSession
    @Environment(\.colorScheme) var colorScheme

    var isSignInEnabled: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(colorScheme == .dark ? "waver_logo" : "waver_logo_black")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 30)

                    Spacer()

                    Text("Real reports from real surfers.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .foregroundColor(Color.primary)

                    Text("Log in to your Waver account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .tint(Color.primary)
                            .foregroundColor(Color.primary)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding(18)
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary, lineWidth: 1))

                        SecureField("Password", text: $password)
                            .tint(Color.primary)
                            .foregroundColor(Color.primary)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .padding(18)
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: {
                            showingReset = true
                        }) {
                            Text("Forgot your password?")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    try await userSession.signIn(email: email, password: password)
                                } catch {
                                    let message = error.localizedDescription.lowercased()

                                    if message.contains("email") && message.contains("confirm") {
                                        try? await SupabaseService.shared.resendConfirmationEmail(email: email)
                                        errorMessage = "Your email isn't confirmed yet. We've sent you a new confirmation link—be sure to check your spam folder."
                                    } else {
                                        errorMessage = error.localizedDescription
                                    }

                                    showingErrorAlert = true
                                }
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(isSignInEnabled ? Color.primary : Color.secondary.opacity(0.2))
                        .foregroundColor(isSignInEnabled ? Color(.systemBackground) : .gray)
                        .cornerRadius(10)
                        .disabled(!isSignInEnabled)

                        Button(action: {
                            isRegistering = true
                        }) {
                            Text("Don't have an account? **Create one**")
                                .font(.footnote)
                                .foregroundColor(Color.primary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .sheet(isPresented: $showingReset) {
                ResetPasswordView()
            }
            .alert("Sign In Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}
