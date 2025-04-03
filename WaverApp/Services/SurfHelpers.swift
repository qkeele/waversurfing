//
//  SurfHelpers.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import SwiftUI

/// Convert rating 0..3 → text
func textForRating(_ rating: Int) -> String {
    switch rating {
    case 3: return "Epic"
    case 2: return "Good"
    case 1: return "Okay"
    default: return "Bad"
    }
}

/// Convert rating 0..3 → color
func colorForRating(_ rating: Int) -> Color {
    switch rating {
    case 3:
        return Color.purple    // epic
    case 2:
        return Color.green     // good
    case 1:
        return Color.yellow    // fine
    default:
        return Color.red       // bad
    }
}

/// Convert 0..3 crowd to descriptive word
func textForCrowd(_ averageCrowd: Double) -> String {
    let crowdInt = Int(averageCrowd.rounded())
    switch crowdInt {
    case 3: return "packed"
    case 2: return "busy"
    case 1: return "light"
    default: return "empty"
    }
}

/// Convert 0..9 wave height to descriptive text
func textForHeight(_ averageHeight: Double) -> String {
    let waveInt = Int(averageHeight.rounded())
    switch waveInt {
    case 1: return "ankle high"
    case 2: return "knee high"
    case 3: return "thigh high"
    case 4: return "waist high"
    case 5: return "chest high"
    case 6: return "head high"
    case 7: return "overhead"
    case 8: return "well overhead"
    case 9: return "double overhead"
    default: return "flat"
    }
}

func numsForHeight(_ averageHeight: Double) -> String {
    let waveInt = Int(averageHeight.rounded())
    switch waveInt {
    case 1: return "1/2ft"
    case 2: return "1ft"
    case 3: return "1-2ft"
    case 4: return "2-3ft"
    case 5: return "3-4ft"
    case 6: return "4-5ft"
    case 7: return "5-7ft"
    case 8: return "8-10ft"
    case 9: return "10-15ft"
    default: return "0ft"
    }
}

func dominantRating(in dist: RatingDistribution) -> Int {
    let segments = [
        (rating: 3, count: dist.rating3Count),
        (rating: 2, count: dist.rating2Count),
        (rating: 1, count: dist.rating1Count),
        (rating: 0, count: dist.rating0Count)
    ]
    var bestRating = 0
    var bestCount = -1
    for seg in segments {
        if seg.count > bestCount {
            bestCount = seg.count
            bestRating = seg.rating
        } else if seg.count == bestCount, seg.rating > bestRating {
            bestRating = seg.rating
        }
    }
    return bestRating
}
