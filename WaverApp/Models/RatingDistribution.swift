//
//  RatingDistribution.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import Foundation

struct RatingDistribution {
    let rating0Count: Int
    let rating1Count: Int
    let rating2Count: Int
    let rating3Count: Int

    var total: Int {
        rating0Count + rating1Count + rating2Count + rating3Count
    }
}
