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
    @State private var isPasswordVisible = false
    @FocusState private var isPasswordFocused: Bool


    @ObservedObject private var usernameValidator = UsernameValidator()
    @Binding var isRegistering: Bool

    @State private var isLoading = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    @EnvironmentObject var userSession: UserSession
    @Environment(\.colorScheme) var colorScheme

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
                        .font(.title2).bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .foregroundColor(Color.primary)

                    Text("Join the community and document your sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack(spacing: 12) {
                        HStack {
                            TextField("Username", text: $username)
                                .tint(Color.primary)
                                .foregroundColor(Color.primary)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .onChange(of: username) {
                                    usernameValidator.checkAvailability(username: username)
                                }

                            ValidationIcon(isValid: usernameValidator.isAvailable)
                        }
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary))

                        HStack {
                            TextField("Email", text: $email)
                                .tint(Color.primary)
                                .foregroundColor(Color.primary)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                            ValidationIcon(isValid: Validator.isValidEmail(email))
                        }
                        .padding(18)
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary))

                        ZStack(alignment: .trailing) {
                            Group {
                                if isPasswordVisible {
                                    // Normal TextField
                                    TextField("Password", text: $password)
                                        .focused($isPasswordFocused)
                                } else {
                                    // SecureField
                                    SecureField("Password", text: $password)
                                        .focused($isPasswordFocused)
                                }
                            }
                            // Common modifiers for both fields
                            .tint(Color.primary)
                            .foregroundColor(Color.primary)
                            .padding(18)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.primary))

                            // Eye toggle button
                            Button {
                                let wasFocused = isPasswordFocused
                                isPasswordVisible.toggle()

                                // If it was focused before toggling, refocus to keep the keyboard open
                                if wasFocused {
                                    DispatchQueue.main.async {
                                        isPasswordFocused = true
                                    }
                                }
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .padding(.trailing, 18)  // Matches the text padding
                                    .foregroundColor(.primary)
                            }
                        }


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
                                    try await SupabaseService.shared.registerUser(email: email, password: password, username: username)
                                    DispatchQueue.main.async {
                                        showConfirmation = true
                                    }
                                } catch {
                                    DispatchQueue.main.async {
                                        errorMessage = error.localizedDescription
                                        showingErrorAlert = true
                                    }
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
                        .background(canRegister ? Color.primary : Color.secondary.opacity(0.2))
                        .foregroundColor(canRegister ? Color(.systemBackground) : .gray)
                        .cornerRadius(10)
                        .disabled(!canRegister || isLoading)

                        Button("Already have an account? **Sign in**") {
                            isRegistering = false
                        }
                        .font(.footnote)
                        .foregroundColor(Color.primary)
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
            .sheet(isPresented: $showConfirmation, onDismiss: {
                isRegistering = false
            }) {
                RegistrationConfirmationView()
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
                .foregroundColor(.secondary)
                .font(.footnote)
        }
    }
}
