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
    let currentUserId: UUID?

    var onUserTap: ((UUID) -> Void)? = nil
    var onSpotTap: ((UUID) -> Void)? = nil
    var onEditTap: ((Report) -> Void)? = nil
    var onDeleteTap: ((Report) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        if let username = username {
                            Text(username)
                                .font(.subheadline)
                                .bold()
                                .onTapGesture { onUserTap?(report.user_id) }
                        }

                        if username != nil && spotName != nil {
                            Text("at")
                                .font(.subheadline)
                                .bold()
                        }

                        if let spotName = spotName {
                            Text(spotName)
                                .font(.subheadline)
                                .bold()
                                .onTapGesture { onSpotTap?(report.spot_id) }
                        }

                        Text(formatTimestamp(report.timestamp, showFullDate: showFullDate))
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

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

                Spacer()

                if report.user_id == currentUserId {
                    Menu {
                        Button("Edit") {
                            onEditTap?(report)
                        }
                        Button("Delete", role: .destructive) {
                            onDeleteTap?(report)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(.systemGray))
                            .padding(.leading, 4)
                    }
                }
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
                formatter.dateFormat = "'Today' • h:mm a"
            } else {
                formatter.dateFormat = "MMM d, yyyy • h:mm a"
            }
        } else {
            formatter.dateFormat = "h:mm a"
        }

        return formatter.string(from: date)
    }
}

