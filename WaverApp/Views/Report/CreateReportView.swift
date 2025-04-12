//
//  CreateReportView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct CreateReportView: View {
    let spot: Spot
    var onReportSubmitted: (() -> Void)? // ✅ Completion handler
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedRating: Int? = nil
    @State private var selectedHeight: Int? = nil
    @State private var selectedCrowd: Int? = nil
    @State private var selectedVisibility: String? = "public"
    @State private var comment: String = ""
    @State private var isSubmitting = false // ✅ Track submission state
    @State private var showConfirmation = false // ✅ State for confirmation modal


    var body: some View {
        ZStack{
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
                                ProgressView() // ✅ Show loading indicator when submitting
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Submit")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background((selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? invertedColor() : Color.gray) // ✅ Fixed
                        .foregroundColor((selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? backgroundColor() : .white) // ✅ Fixed
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: (selectedRating != nil && selectedHeight != nil && selectedCrowd != nil) ? invertedColor().opacity(0.5) : Color.clear, radius: 10) // ✅ Fixed
                        .animation(.easeInOut(duration: 0.3), value: (selectedRating != nil && selectedHeight != nil && selectedCrowd != nil)) // ✅ Fixed
                        .disabled(selectedRating == nil || selectedHeight == nil || selectedCrowd == nil || isSubmitting) // ✅ Replace isValid()
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                .navigationTitle("New Report")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(.systemBackground), for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                //.imageScale(.small)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
            }
            // ✅ Move confirmation view OUTSIDE the NavigationView
            if showConfirmation {
                ReportConfirmationView {
                    showConfirmation = false
                    dismiss()
                }
                .transition(.opacity) // ✅ Smooth fade-in effect
                .animation(.easeInOut, value: showConfirmation)
            }
        }
    }

    private func submitReport() {
        guard let rating = selectedRating, let height = selectedHeight, let crowd = selectedCrowd, let visibility = selectedVisibility else { return }
        guard let userId = userSession.currentUser?.id else { return }

        let reportService = ReportService()

        isSubmitting = true // ✅ Prevent multiple submissions

        Task {
            do {
                try await reportService.addReport(
                    forUser: userId,
                    spotId: spot.id,
                    rating: rating,
                    height: height,
                    crowd: crowd,
                    comment: comment.isEmpty ? nil : comment,
                    visibility: visibility
                )
                print("Report successfully added!")
                // ✅ Notify `ReportListView` before dismissing
                onReportSubmitted?()
                showConfirmation = true
                
            } catch {
                print("Error adding report: \(error)")
            }

            isSubmitting = false // ✅ Re-enable button after submission
        }
    }

    private func invertedColor() -> Color {
        return colorScheme == .dark ? Color.white : Color.black
    }

    private func backgroundColor() -> Color {
        return colorScheme == .dark ? Color.black : Color.white
    }
}
