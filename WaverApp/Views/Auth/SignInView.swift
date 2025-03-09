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
    
    var isSignInEnabled: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("waver_logo")
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

                    Text("Log in to your Waver account")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(spacing: 12) {
                        TextField("Email", text: $email)
                            .tint(.white)
                            .foregroundColor(.white)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding(18)
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))

                        SecureField("Password", text: $password)
                            .tint(.white)
                            .foregroundColor(.white)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .padding(18)
                            .frame(height: 50)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: {
                            showingReset = true
                        }) {
                            Text("Forgot your password?")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    try await userSession.signIn(email: email, password: password)
                                } catch {
                                    errorMessage = error.localizedDescription
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
                        .background(isSignInEnabled ? .white : .white.opacity(0.2))
                        .foregroundColor(isSignInEnabled ? .black : .gray)
                        .cornerRadius(10)
                        .disabled(!isSignInEnabled)

                        Button(action: {
                            isRegistering = true
                        }) {
                            Text("Don't have an account? **Create one**")
                                .font(.footnote)
                                .foregroundColor(.white)
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
