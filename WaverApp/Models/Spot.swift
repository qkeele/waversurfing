//
//  Spot.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//

import Foundation

struct Spot: Identifiable, Codable {
    let id: UUID
    let name: String
    let region: String
    let sub_region: String?
    let sub_sub_region: String?
}
