//
//  Favorite.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation

struct Favorite: Identifiable, Codable {
    let id: UUID
    let user_id: UUID
    let spot_id: UUID
}
