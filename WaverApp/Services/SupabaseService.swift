//
//  SupabaseService.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation
import Supabase

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
            let secrets = SupabaseService.loadSecrets()

            self.client = SupabaseClient(
                supabaseURL: URL(string: secrets.url)!,
                supabaseKey: secrets.key
            )
        }
    
    // MARK: - Global Auth Methods
    
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func registerUser(email: String, password: String, username: String) async throws {
        // Sign up in Supabase Auth
        let authResponse = try await client.auth.signUp(
            email: email,
            password: password,
            redirectTo: URL(string: "https://www.waversurfing.com/confirmation")!
        )

        let authID = authResponse.user.id

        // Immediately insert into 'users' table
        try await client
            .from("users")
            .insert([
                "auth_id": authID.uuidString,
                "email": email,
                "username": username,
                "timestamp": Date().ISO8601Format()
            ])
            .execute()
    }
    
    func resendConfirmationEmail(email: String) async throws {
        try await client.auth.resend(
            email: email, type: .signup
        )
    }

    func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    private static func loadSecrets() -> (url: String, key: String) {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path) else {
            fatalError("ERROR: Could not find Secrets.plist")
        }

        var format = PropertyListSerialization.PropertyListFormat.xml
        do {
            let plistData = try PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: &format)
            if let dict = plistData as? [String: String],
               let url = dict["SUPABASE_URL"],
               let key = dict["SUPABASE_KEY"] {
                return (url, key)
            }
        } catch {
            fatalError("ERROR: Could not read Secrets.plist: \(error)")
        }
        fatalError("ERROR: Secrets.plist is missing required keys.")
    }
}
