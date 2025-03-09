//
//  AuthHelpers.swift
//  Waver
//
//  Created by Quincy Keele on 2/23/25.
//

import SwiftUI
import Supabase

class UsernameValidator: ObservableObject {
    @Published var isAvailable: Bool? = nil
    
    private var debounceTimer: Timer?

    func checkAvailability(username: String) {
        debounceTimer?.invalidate()
        
        guard username.count >= 3 else {
            isAvailable = false
            return
        }
        
        // Wait briefly after typing stops (debouncing)
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task {
                await self.validateUsername(username)
            }
        }
    }

    private func validateUsername(_ username: String) async {
        do {
            let existingUsers: [User] = try await SupabaseService.shared.client
                .from("users")
                .select("id")
                .eq("username", value: username.lowercased())
                .execute()
                .value

            await MainActor.run {
                self.isAvailable = existingUsers.isEmpty
            }
        } catch {
            print("Error checking username availability:", error.localizedDescription)
            await MainActor.run {
                self.isAvailable = false
            }
        }
    }
}


struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    static func passwordHasSymbolAndNumber(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$&*._-]).+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
}
