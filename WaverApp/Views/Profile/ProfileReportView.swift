//
//  ProfileReportListVIew.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct ProfileReportView: View {
    let report: Report
    let spotName: String? // ✅ Spot name is passed in from ProfileView
    @ObservedObject var dataManager: SurfDataManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(spotName ?? "Unknown Spot")
                    .font(.headline)
                
                Text(textForRating(report.rating))
                    .foregroundColor(colorForRating(report.rating))
                    .bold()
                
                Text("\(textForHeight(Double(report.height))) and \(textForCrowd(Double(report.crowd)))")
            }
            .font(.subheadline)

            // ✅ Display Timestamp
            Text(formatTimestamp(report.timestamp))
                .font(.footnote)
                .foregroundColor(.gray)

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

    /// ✅ Formats the timestamp for better readability
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a" // Example: Feb 26, 2025 • 2:15 PM
        return formatter.string(from: date)
    }
}

