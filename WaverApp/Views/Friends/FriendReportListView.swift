//
//  FriendsReportView.swift
//  Waver
//
//  Created by Quincy Keele on 4/14/25.
//

import SwiftUI

struct FriendReportListView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @StateObject private var service = ReportService()

    @State private var reports: [Report] = []
    @State private var usernames: [UUID: String] = [:]
    @State private var spotNames: [UUID: String] = [:] // key: report.id
    @State private var isLoading = true
    @State private var selectedUserId: IdentifiableUUID?
    @State private var selectedSpotId: IdentifiableUUID?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Top bar with X
                HStack {
                    Text("Friend Reports")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))

                // Main content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                } else if reports.isEmpty {
                    Spacer()
                    Text("No reports from friends today.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(reports, id: \.id) { report in
                                let isOwner = report.user_id == userSession.currentUser?.id
                                UnifiedReportView(
                                    report: report,
                                    username: usernames[report.user_id],
                                    spotName: spotNames[report.id], showFullDate: false,
                                    currentUserId: isOwner ? userSession.currentUser?.id : nil,
                                    onUserTap: { selectedUserId = IdentifiableUUID(id: $0) },
                                    onSpotTap: { selectedSpotId = IdentifiableUUID(id: $0) }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .sheet(item: $selectedUserId) { identifiable in
                NavigationStack {
                    UserProfileViewLoader(userId: identifiable.id)
                }
            }
            .sheet(item: $selectedSpotId) { identifiable in
                NavigationStack {
                    SpotReportListViewLoader(spotId: identifiable.id)
                }
            }
            .task {
                await loadReports()
            }
        }
    }

    private func loadReports() async {
        guard let userId = userSession.currentUser?.id else { return }
        do {
            let fetchedReports = try await service.fetchFriendReports(authId: userId)
            reports = fetchedReports

            var usernamesResult: [UUID: String] = [:]
            var spotNamesResult: [UUID: String] = [:]

            await withTaskGroup(of: (UUID, String?, UUID, String?).self) { group in
                for report in fetchedReports {
                    group.addTask {
                        async let username = UserService.shared.fetchUsername(for: report.user_id)
                        async let spotName = SpotService().getSpotNameWithReportId(reportID: report.id)

                        return (report.user_id, await username, report.id, try? await spotName)
                    }
                }

                for await (userId, username, reportId, spotName) in group {
                    if let username = username {
                        usernamesResult[userId] = username
                    }
                    if let spotName = spotName {
                        spotNamesResult[reportId] = spotName
                    }
                }
            }

            DispatchQueue.main.async {
                self.usernames = usernamesResult
                self.spotNames = spotNamesResult
                self.isLoading = false
            }
        } catch {
            print("Error loading friend reports or metadata: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
}
