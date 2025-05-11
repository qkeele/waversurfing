//
//  WaverUser.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation

struct WaverUser: Identifiable, Codable {
    let id: UUID
    let authID: UUID?
    let username: String
    let email: String?
    let timestamp: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case authID = "auth_id"
        case username
        case email
        case timestamp
    }

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let primaryFormat = DateFormatter()
            primaryFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            primaryFormat.locale = Locale(identifier: "en_US_POSIX")
            primaryFormat.timeZone = TimeZone(secondsFromGMT: 0)

            let fallbackFormat = DateFormatter()
            fallbackFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            fallbackFormat.locale = Locale(identifier: "en_US_POSIX")
            fallbackFormat.timeZone = TimeZone(secondsFromGMT: 0)

            if let date = primaryFormat.date(from: dateString) {
                return date
            } else if let fallbackDate = fallbackFormat.date(from: dateString) {
                return fallbackDate
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string: \(dateString)"
            )
        }

        return decoder
    }()
}
