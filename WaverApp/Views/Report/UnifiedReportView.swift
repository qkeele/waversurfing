//
//  UnifiedReportView.swift
//  Waver
//
//  Created by Quincy Keele on 4/14/25.
//

import SwiftUI

struct UnifiedReportView: View {
    let report: Report
    let username: String?
    let spotName: String?
    let showFullDate: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                if let username = username {
                    Text(username)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                if let spotName = spotName {
                    Text("\(spotName)")
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Text(formatTimestamp(report.timestamp, showFullDate: showFullDate))
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

    func formatTimestamp(_ date: Date, showFullDate: Bool) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if showFullDate {
            if calendar.isDateInToday(date) {
                formatter.dateFormat = "'Today ' h:mm a"
            } else {
                formatter.dateFormat = "MMM d, yyyy • h:mm a"
            }
        } else {
            formatter.dateFormat = "h:mm a"
        }

        return formatter.string(from: date)
    }
}

