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
    @State private var isShowingContactSheet = false // ✅ State for contact modal
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
                .background(Color(UIColor.systemBackground)) // Match system background
                
                // Settings List
                List {
                    Section {
                        Button {
                            isShowingContactSheet = true // ✅ Opens the contact modal
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text("Contact Us")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
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
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.primary)
                                Text("Sign Out")
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("Delete Account")
                                    .foregroundColor(.red)
                                Spacer()
                            }
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
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden) // Remove default list background
            }
        }
        .sheet(isPresented: $isShowingContactSheet) {
            ContactSheet()
        }
    }
}

// ✅ Contact Sheet View
struct ContactSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Contact Us")
                .font(.title2)
                .bold()
            Text("For feedback, support, or inquiries reach us at:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("waversurfing@gmail.com")
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.fraction(0.3)])
    }
}
