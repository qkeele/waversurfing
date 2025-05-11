//
//  PreferencesView.swift
//  Waver
//
//  Created by Quincy Keele on 2/22/25.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @State private var isShowingContactSheet = false
    @State private var showDeleteAlert = false

    let userService = UserService.shared

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground)) // system-consistent background
                .zIndex(1)

                // Settings
                Form {
                    Section {
                        Button {
                            isShowingContactSheet = true
                        } label: {
                            Label("Contact", systemImage: "envelope")
                                .foregroundColor(.primary)
                        }
                    }

                    Section {
                        Button(role: .cancel) {
                            Task {
                                do {
                                    try await userSession.signOut()
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
                        } label: {
                            Label("Sign Out", systemImage: "arrow.right.circle")
                                .foregroundColor(.primary)
                        }

                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .alert("Delete Account?", isPresented: $showDeleteAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                Task {
                                    if let userId = userSession.currentUser?.id {
                                        await userService.requestAccountDeletion(userId: userId)
                                        try await userSession.signOut()
                                    } else {
                                        print("❌ Error: User ID is nil.")
                                    }
                                }
                            }
                        } message: {
                            Text("Your data will be deleted within 30 days.")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemGroupedBackground)) // fills background properly
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        }
        .sheet(isPresented: $isShowingContactSheet) {
            ContactSheet()
        }
    }
}
