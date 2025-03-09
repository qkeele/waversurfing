//
//  RegisterView.swift
//  Waver
//
//  Created by Quincy Keele on 2/23/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var showConfirmation = false
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""

    @ObservedObject private var usernameValidator = UsernameValidator()
    @Binding var isRegistering: Bool

    @State private var isLoading = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    @EnvironmentObject var userSession: UserSession

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
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    Text("Join the community and document your sessions")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(spacing: 12) {
                        HStack {
                            TextField("Username", text: $username)
                                .tint(.white).foregroundColor(.white)
                                .autocorrectionDisabled().textInputAutocapitalization(.never)
                                .onChange(of: username) {
                                    usernameValidator.checkAvailability(username: username)
                                }

                            ValidationIcon(isValid: usernameValidator.isAvailable)
                        }
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))

                        HStack {
                            TextField("Email", text: $email)
                                .tint(.white).foregroundColor(.white)
                                .autocorrectionDisabled().textInputAutocapitalization(.never)

                            ValidationIcon(isValid: Validator.isValidEmail(email))
                        }
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))

                        SecureField("Password", text: $password)
                            .tint(.white).foregroundColor(.white)
                            .padding(18)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))

                        VStack(alignment: .leading, spacing: 4) {
                            criteriaRow(text: "Includes letters, a number, and a symbol",
                                        isMet: Validator.passwordHasSymbolAndNumber(password))
                            criteriaRow(text: "At least 8 characters",
                                        isMet: password.count >= 8)
                        }
                        .padding(.horizontal, 8).padding(.top, 4)
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                isLoading = true
                                do {
                                    print("➡️ Attempting to register user: \(email)")

                                    try await SupabaseService.shared.registerUser(email: email, password: password, username: username)

                                    print("✅ User registered successfully.")

                                    DispatchQueue.main.async {
                                        showConfirmation = true
                                    }

                                    print("➡️ showConfirmation set to true")
                                    
                                } catch {
                                    DispatchQueue.main.async {
                                        errorMessage = error.localizedDescription
                                        showingErrorAlert = true
                                    }
                                    print("❌ Error during registration: \(error)")
                                }
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity).padding()
                            }
                        }

                        .background(canRegister ? .white : .white.opacity(0.2))
                        .foregroundColor(canRegister ? .black : .gray)
                        .cornerRadius(10)
                        .disabled(!canRegister || isLoading)

                        Button("Already have an account? **Sign in**") {
                            isRegistering = false
                        }
                        .font(.footnote).foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .alert("Registration Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showConfirmation) {
                RegistrationConfirmationView(didDismiss: {
                    DispatchQueue.main.async {
                        isRegistering = false
                    }
                })
            }
        }
    }

    var canRegister: Bool {
        usernameValidator.isAvailable == true &&
        Validator.isValidEmail(email) &&
        Validator.passwordHasSymbolAndNumber(password) &&
        password.count >= 8
    }

    @ViewBuilder
    func criteriaRow(text: String, isMet: Bool) -> some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(isMet ? .green : .red)
            Text(text)
                .foregroundColor(.gray)
                .font(.footnote)
        }
    }
}
