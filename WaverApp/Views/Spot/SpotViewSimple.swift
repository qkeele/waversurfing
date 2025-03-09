//
//  SpotViewSimple.swift
//  Waver
//
//  Created by Quincy Keele on 2/22/25.
//

import SwiftUI

struct SpotViewSimple: View {
    let spot: Spot
    let distribution: RatingDistribution
    let averageHeight: Double
    let totalReports: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(spot.name)
                .font(.title3).bold() // Larger spot name
            
            Spacer()

            if totalReports > 0 {
                Text(numsForHeight(averageHeight))
                    .font(.body)

                let dom = dominantRating(in: distribution)
                Text(textForRating(dom))
                    .font(.body).bold()
                    .foregroundColor(colorForRating(dom))
            } else {
                Text("⏤") // ✅ Show dashes instead of 0ft
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}
