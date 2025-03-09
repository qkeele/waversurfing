//
//  Report.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation

struct Report: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let spot_id: UUID
    let rating: Int
    let height: Int
    let crowd: Int
    let comment: String?
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case spot_id
        case rating
        case height
        case crowd
        case comment
        case timestamp
    }

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure UTC alignment
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
}
