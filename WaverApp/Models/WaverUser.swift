//
//  WaverUser.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation

struct WaverUser: Codable {
    let id: UUID
    let authID: UUID
    let username: String
    let email: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case authID = "auth_id"
        case username
        case email
        case timestamp
    }

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Matches Supabase format
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures strict formatting
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}
