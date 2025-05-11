//
//  AppRoute.swift
//  Waver
//
//  Created by Sydney Del Fosse on 5/8/25.
//


import Foundation

enum AppRoute: Hashable {
    case user(UUID)
    case spot(UUID)
    case report(UUID)
}

struct IdentifiableUUID: Identifiable, Hashable {
    let id: UUID
}
