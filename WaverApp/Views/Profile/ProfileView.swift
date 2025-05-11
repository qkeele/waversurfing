//
//  ProfileView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var dataManager: SurfDataManager
    @StateObject private var reportService = ReportService()
    @Environment(\.presentationMode) var presentationMode
    @State private var reports: [(Report, String?)] = [] // ✅ Store reports & spot names
    @State private var isLoading = true // ✅ Track loading state
    @State private var isPreferencesPresented = false // ✅ Toggle PreferencesView
    @State private var isFriendsPresented = false
    @State private var selectedSpotId: IdentifiableUUID?
    @State private var selectedReport: Report?
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            // ✅ Top Bar (Username + Settings + Close)
            HStack {
                let username = userSession.currentUser?.username
                Text(username ?? "")
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Spacer()
                
                // 👥 Friends Button
                Button(action: {
                    isFriendsPresented.toggle()
                }) {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 8)


                // ⚙️ Preferences Button
                Button(action: {
                    isPreferencesPresented.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .padding(.trailing, 8) // ✅ Space between gear and close button
                
                // ❌ Close Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()

            // ✅ Show a single ProgressView until everything is loaded
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle()) // ✅ Proper spinner
                    .scaleEffect(1.5) // ✅ Make spinner bigger
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
                                onSpotTap: { selectedSpotId = IdentifiableUUID(id: $0) },
                                onEditTap: isOwner ? { selectedReport = $0 } : nil,
                                onDeleteTap: isOwner ? { selectedReport = $0; showDeleteConfirmation = true } : nil
                            )
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .task {
            await fetchReports() // ✅ Fetch all reports before displaying
        }
        // ✅ Show PreferencesView when toggled
        .sheet(isPresented: $isPreferencesPresented) {
            PreferencesView()
        }
        .sheet(isPresented: $isFriendsPresented) {
            FriendManagementView()
        }
        .sheet(item: $selectedSpotId) { identifiable in
            NavigationStack {
                SpotReportListViewLoader(spotId: identifiable.id)
            }
        }
    }
    
    private func spotName(for spotId: UUID) -> String {
        reports.first(where: { $0.0.spot_id == spotId })?.1 ?? "Unknown Spot"
    }

    private func fetchReports() async {
        guard let userId = userSession.currentUser?.id else { return }
        do {
            let fetchedReports = try await reportService.fetchReportsForUser(userId: userId)

            // ✅ Use TaskGroup to load spot names concurrently (faster loading)
            var loadedReports: [(Report, String?)] = []
            await withTaskGroup(of: (Report, String?).self) { group in
                for report in fetchedReports {
                    group.addTask {
                        let spotName = try? await SpotService().getSpotNameWithReportId(reportID: report.id)
                        return (report, spotName)
                    }
                }

                // ✅ Collect results and update reports array
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
                self.isLoading = false // ✅ Hide loader even if there's an error
            }
        }
    }
}
