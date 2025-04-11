//
//  Search Type.swift
//  Waver
//
//  Created by Quincy Keele on 4/8/25.
//

import Foundation

enum SearchType: String, CaseIterable, Identifiable {
    case spots = "Spots"
    case people = "People"

    var id: String { self.rawValue }
}
