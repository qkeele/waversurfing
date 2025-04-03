//
//  ProfileReportView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct ProfileReportView: View {
    let report: Report
    let spotName: String?
    @ObservedObject var dataManager: SurfDataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(spotName ?? "Unknown Spot")
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(formatTimestamp(report.timestamp))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 4) {
                Text(textForRating(report.rating))
                    .foregroundColor(colorForRating(report.rating))
                    .bold()
                
                Text("•")
                
                Text("\(textForHeight(Double(report.height))) and \(textForCrowd(Double(report.crowd)))")
            }
            .font(.subheadline)
            
            if let comment = report.comment, !comment.isEmpty {
                Text(comment)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}
