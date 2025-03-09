//
//  ReportSelectionView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct ReportSelectionView: View {
    @Binding var selectedRating: Int?
    @Binding var selectedHeight: Int?
    @Binding var selectedCrowd: Int?
    var colorScheme: ColorScheme

    var body: some View {
        VStack(spacing: 24) {
            // "How was it?" selection (rating 0-3)
            VStack(alignment: .leading, spacing: 12) {
                Text("How was it?")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    ForEach(0...3, id: \.self) { rating in // ✅ Only allows 0-3
                        Button(action: { selectedRating = rating }) {
                            Text(textForRating(rating))
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedRating == rating ? colorForRating(rating) : Color(.systemGray5))
                                .foregroundColor(selectedRating == rating ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal)

            // "How big was it?" selection (height 0-9)
            VStack(alignment: .leading, spacing: 12) {
                Text("How big was it?")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack {
                    ForEach(0...9, id: \.self) { height in // ✅ Only allows 0-9
                        Button(action: { selectedHeight = height }) {
                            Text(textForHeight(Double(height)))
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(selectedHeight == height ? invertedColor() : Color(.systemBackground))
                                .foregroundColor(selectedHeight == height ? backgroundColor() : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .padding(.horizontal)

            // "How was the crowd?" selection (crowd 0-3)
            VStack(alignment: .leading, spacing: 12) {
                Text("How was the crowd?")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack {
                    ForEach(0...3, id: \.self) { crowd in // ✅ Only allows 0-3
                        Button(action: { selectedCrowd = crowd }) {
                            Text(textForCrowd(Double(crowd)))
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedCrowd == crowd ? invertedColor() : Color(.systemBackground))
                                .foregroundColor(selectedCrowd == crowd ? backgroundColor() : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func invertedColor() -> Color {
        return colorScheme == .dark ? Color.white : Color.black
    }

    private func backgroundColor() -> Color {
        return colorScheme == .dark ? Color.black : Color.white
    }
}
