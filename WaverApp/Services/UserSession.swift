//
//  UserSession.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import SwiftUI
import Supabase

@MainActor
class UserSession: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: WaverUser? = nil
    @Published var session: Session? = nil
    @Published var isSessionLoaded = false
    
    // MARK: - Dependencies
    
    /// Reference your existing SupabaseClient from SupabaseService
    private let client = SupabaseService.shared.client
    
    // MARK: - Initialization
    
    init() {
        // On creation, try to load any existing session from cache
        Task {
            await loadActiveSession()
        }
    }
    
    // MARK: - Load Active Session
    
    /// Attempts to load a cached session from supabase-swift. If successful, fetches the matching WaverUser.
    func loadActiveSession() async {
        do {
            // This tries to load an existing session (if any) from local storage
            let existingSession = try await client.auth.session
            self.session = existingSession
            
            try await loadWaverUser(authID: existingSession.user.id)
        } catch {
            // If no session or error, clear local user/session
            self.session = nil
            self.currentUser = nil
            print("Error loading session: \(error)")
        }
        isSessionLoaded = true
    }
    
    // MARK: - Load WaverUser
    
    private func loadWaverUser(authID: UUID) async throws {
        let responseData = try await client
            .from("users")
            .select("id, auth_id, username, email, timestamp::text") // Force timestamp to text
            .eq("auth_id", value: authID.uuidString)
            .single()
            .execute()
            .data

        let user = try WaverUser.decoder.decode(WaverUser.self, from: responseData)
        self.currentUser = user
    }
    
    // MARK: - Sign In
    
    /// Signs in with email and password, then loads the matching WaverUser.
    func signIn(email: String, password: String) async throws {
        do {
            try await SupabaseService.shared.signIn(email: email, password: password)

            let newSession = try await client.auth.session
            self.session = newSession

            try await loadWaverUser(authID: newSession.user.id)
        } catch {
            throw error
        }
    }
    
    // MARK: - Refresh Session
    
    /// Forcibly refreshes the session token to keep the user logged in.
    func refreshSession() async throws {
        do {
            let refreshedSession = try await client.auth.refreshSession()
            self.session = refreshedSession
            
            try await loadWaverUser(authID: refreshedSession.user.id)
        } catch {
            throw error
        }
    }
    
    // MARK: - Sign Out
    
    /// Signs out of the current session, clears local user state.
    func signOut() async throws {
        do {
            try await client.auth.signOut()
            self.session = nil
            self.currentUser = nil
        } catch {
            throw error
        }
    }
}
