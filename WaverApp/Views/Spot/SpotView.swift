//
//  SpotView.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import SwiftUI

struct SpotView: View {
    let spot: Spot
    let distribution: RatingDistribution
    let averageHeight: Double
    let averageCrowd: Double
    let totalReports: Int
    let isLoading: Bool // ✅ Add loading state

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            //Text(spot.name)
                //.font(.headline)

            if isLoading {
                // ✅ Show spinner while data is loading
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    Spacer()
                }
                .padding()
            } else if totalReports > 0 {
                Text("Waves are \(textForHeight(averageHeight)), the lineup is \(textForCrowd(averageCrowd)).")
                    .foregroundColor(.primary)

                let dom = dominantRating(in: distribution)
                Text(textForRating(dom))
                    .foregroundColor(colorForRating(dom))
                    .bold()

                distributionBar

                Text("\(totalReports) reports")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                Text("0 reports")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(radius: 3)
    }
    
    private var distributionBar: some View {
        GeometryReader { geo in
            let total = Double(distribution.total)
            HStack(spacing: 0) {
                if total > 0 {
                    let segments = [
                        (3, distribution.rating3Count),
                        (2, distribution.rating2Count),
                        (1, distribution.rating1Count),
                        (0, distribution.rating0Count)
                    ]
                    let sorted = segments.sorted {
                        if $0.1 == $1.1 { return $0.0 > $1.0 }
                        return $0.1 > $1.1
                    }
                    ForEach(sorted, id: \.0) { seg in
                        if seg.1 > 0 {
                            Rectangle()
                                .fill(colorForRating(seg.0))
                                .frame(width: geo.size.width * CGFloat(Double(seg.1)/total))
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
        }
        .frame(height: 20)
        .cornerRadius(4)
    }
}
