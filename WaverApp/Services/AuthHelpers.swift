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

    // Minimum and maximum length allowed for the username.
    private let minLength = 3
    private let maxLength = 16

    /// Checks if the username meets the format rules:
    ///  - 3-16 characters in total
    ///  - Alphanumeric, underscore, and period allowed
    ///  - No leading/trailing period
    ///  - No consecutive periods
    ///  - Underscores can appear anywhere (leading, trailing, consecutive, etc.)
    private func meetsFormatRequirements(_ username: String) -> Bool {
        // Explanation of the pattern:
        // ^(?!\\.)         - not start with a period
        // (?!.*\\.$)       - not end with a period
        // (?!.*\\.{2})     - no consecutive periods ("..")
        // [A-Za-z0-9._]{3,16}$ - only letters, digits, underscores, periods; length 3-16
        let pattern = """
        ^(?!\\.)         # no leading period
        (?!.*\\.$)       # no trailing period
        (?!.*\\.{2})     # no consecutive periods
        [A-Za-z0-9._]{\(minLength),\(maxLength)}$
        """
        
        // Combine into a single NSRegularExpression (ignore whitespace/comments in the pattern)
        let options: NSRegularExpression.Options = [.allowCommentsAndWhitespace]
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        
        let range = NSRange(location: 0, length: username.utf16.count)
        return regex.firstMatch(in: username, options: [], range: range) != nil
    }

    func checkAvailability(username: String) {
        debounceTimer?.invalidate()
        
        // First, check basic format requirements
        guard meetsFormatRequirements(username) else {
            // If username doesn't match the rules, mark as not available (or set to nil if you prefer).
            isAvailable = false
            return
        }
        
        // Debounce the server check to avoid rapid calls while typing
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task {
                await self.validateUsername(username)
            }
        }
    }

    private func validateUsername(_ username: String) async {
        do {
            let normalized = username.lowercased()
            
            let existingUsers: [User] = try await SupabaseService.shared.client
                .from("users")
                .select("id")
                .eq("username", value: normalized)
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
