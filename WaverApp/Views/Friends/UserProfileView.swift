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
    @ObservedObject var dataManager = SurfDataManager()
    @StateObject private var reportService = ReportService()
    @StateObject private var toastManager = ToastManager()
    @Environment(\.dismiss) private var dismiss
    @State private var reports: [(Report, String?)] = []
    @State private var isLoading = true

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
                            UnifiedReportView(report: report, username: nil, spotName: spotName, showFullDate: true)
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
