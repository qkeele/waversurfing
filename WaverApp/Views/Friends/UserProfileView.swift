//
//  UserProfileView.swift
//  Waver
//
//  Created by Quincy Keele on 4/10/25.
//

import SwiftUI

struct UserProfileView: View {
    let user: WaverUser
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var dataManager: SurfDataManager
    @StateObject private var reportService = ReportService()
    @StateObject private var toastManager = ToastManager()
    @Environment(\.dismiss) private var dismiss
    @State private var reports: [(Report, String?)] = []
    @State private var isLoading = true
    @State private var selectedSpotId: IdentifiableUUID?
    @State private var selectedReport: Report?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            // ✅ Custom Top Bar (Chevron + Username + Plus)
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.primary)
                }

                Text(user.username)
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()

                if userSession.currentUser?.id != user.id {
                    FriendButtonView(
                        myUserId: userSession.currentUser?.id ?? user.id,
                        otherUserId: user.id,
                        toastManager: toastManager
                    )
                }
            }
            .padding()

            // ✅ Show loader
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(reports, id: \.0.id) { report, spotName in
                            let isOwner = report.user_id == userSession.currentUser?.id
                            UnifiedReportView(
                                report: report,
                                username: nil,
                                spotName: spotName,
                                showFullDate: true,
                                currentUserId: isOwner ? userSession.currentUser?.id : nil,
                                onSpotTap: { selectedSpotId = IdentifiableUUID(id: $0) }
                            )
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .task {
            await fetchReports() // ✅ Use the same fetch logic from ProfileView
        }
        .sheet(item: $selectedSpotId) { identifiable in
            NavigationStack {
                SpotReportListViewLoader(spotId: identifiable.id)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topTrailing) {
            if toastManager.isShowing {
                FloatingToastView(message: toastManager.message, backgroundColor: toastManager.color)
                    .padding(.top, 8)
                    .padding(.trailing, 12)
                    .zIndex(999)
            }
        }
    }

    // ✅ Copied directly from ProfileView
    private func fetchReports() async {
        let userId = user.id
        do {
            let fetchedReports = try await reportService.fetchReportsForUser(userId: userId)

            var loadedReports: [(Report, String?)] = []
            await withTaskGroup(of: (Report, String?).self) { group in
                for report in fetchedReports {
                    group.addTask {
                        let spotName = try? await SpotService().getSpotNameWithReportId(reportID: report.id)
                        return (report, spotName)
                    }
                }

                for await result in group {
                    loadedReports.append(result)
                }
            }

            DispatchQueue.main.async {
                self.reports = loadedReports.sorted { $0.0.timestamp > $1.0.timestamp }
                self.isLoading = false
            }
        } catch {
            print("Error fetching user reports: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
