//
//  CreateReportView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct CreateReportView: View {
    let spot: Spot
    var report: Report? = nil // ✅ Allow editing
    var onReportSubmitted: (() -> Void)? = nil

    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedRating: Int? = nil
    @State private var selectedHeight: Int? = nil
    @State private var selectedCrowd: Int? = nil
    @State private var selectedVisibility: String? = "public"
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        Text(spot.name)
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ReportSelectionView(
                            selectedRating: $selectedRating,
                            selectedHeight: $selectedHeight,
                            selectedCrowd: $selectedCrowd,
                            colorScheme: colorScheme
                        )

                        Spacer()

                        CommentInputView(comment: $comment)

                        Spacer()

                        VisibilitySelectorView(selectedVisibility: $selectedVisibility)

                        Spacer()

                        Button(action: submitReport) {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text(report == nil ? "Submit" : "Update") // ✅ Dynamic label
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background((selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? invertedColor() : Color.gray)
                        .foregroundColor((selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? backgroundColor() : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: (selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? invertedColor().opacity(0.5) : Color.clear, radius: 10)
                        .animation(.easeInOut(duration: 0.3), value: (selectedRating != nil && selectedHeight != nil && selectedCrowd != nil))
                        .disabled(selectedRating == nil || selectedHeight == nil || selectedCrowd == nil || isSubmitting)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .navigationTitle(report == nil ? "New Report" : "Edit Report") // ✅ Dynamic title
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(.systemBackground), for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
            }

            if showConfirmation {
                ReportConfirmationView {
                    showConfirmation = false
                    dismiss()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showConfirmation)
            }
        }
        .onAppear {
            prefillFieldsIfEditing()
        }
    }

    private func prefillFieldsIfEditing() {
        if let report = report {
            selectedRating = report.rating
            selectedHeight = report.height
            selectedCrowd = report.crowd
            selectedVisibility = report.visibility
            comment = report.comment ?? ""
        }
    }

    private func submitReport() {
        guard let rating = selectedRating,
              let height = selectedHeight,
              let crowd = selectedCrowd,
              let visibility = selectedVisibility else { return }

        guard let userId = userSession.currentUser?.id else { return }

        let reportService = ReportService()
        isSubmitting = true

        Task {
            do {
                if let existingReport = report {
                    try await reportService.updateReport(
                        reportId: existingReport.id,
                        rating: rating,
                        height: height,
                        crowd: crowd,
                        comment: comment.isEmpty ? nil : comment,
                        visibility: visibility
                    )
                } else {
                    try await reportService.addReport(
                        forUser: userId,
                        spotId: spot.id,
                        rating: rating,
                        height: height,
                        crowd: crowd,
                        comment: comment.isEmpty ? nil : comment,
                        visibility: visibility
                    )
                }
                print("Report successfully added or updated!")
                onReportSubmitted?()
                showConfirmation = true
            } catch {
                print("Error adding/updating report: \(error)")
            }

            isSubmitting = false
        }
    }

    private func invertedColor() -> Color {
        return colorScheme == .dark ? Color.white : Color.black
    }

    private func backgroundColor() -> Color {
        return colorScheme == .dark ? Color.black : Color.white
    }
}
