//
//  ReportListView.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import SwiftUI

struct ReportListView: View {
    let spot: Spot
    @EnvironmentObject var dataManager: SurfDataManager
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    @State private var selectedUserId: IdentifiableUUID?
    @State private var isFavorited = false
    @State private var isCreatingReport = false
    @State private var canSubmit = false
    @State private var hasLoaded = false
    @State private var usernames: [UUID: String] = [:]
    @State private var selectedReport: Report?
    @State private var showDeleteConfirmation = false

    @StateObject private var favoriteService = FavoriteService()
    @StateObject private var reportService = ReportService()

    private var isSearch: Bool {
        !dataManager.spots.contains(where: { $0.id == spot.id })
    }

    var body: some View {
        ZStack {
            if hasLoaded {
                VStack {
                    ScrollView {
                        VStack(spacing: 12) {
                            let reports = isSearch ? dataManager.searchReports : dataManager.reports(for: spot.id)
                            let dist = dataManager.distribution(for: spot.id, isSearch: isSearch)
                            let avgHeight = dataManager.averageHeight(for: spot.id, isSearch: isSearch)
                            let avgCrowd = dataManager.averageCrowd(for: spot.id, isSearch: isSearch)

                            SpotView(
                                spot: spot,
                                distribution: dist,
                                averageHeight: avgHeight,
                                averageCrowd: avgCrowd,
                                totalReports: reports.count,
                                isLoading: false
                            )
                            .padding()

                            ForEach(reports) { report in
                                let isOwner = report.user_id == userSession.currentUser?.id
                                UnifiedReportView(
                                    report: report,
                                    username: usernames[report.user_id],
                                    spotName: nil,
                                    showFullDate: false,
                                    currentUserId: isOwner ? userSession.currentUser?.id : nil,
                                    onUserTap: { selectedUserId = IdentifiableUUID(id: $0) },
                                    onEditTap: isOwner ? { selectedReport = $0 } : nil,
                                    onDeleteTap: isOwner ? { selectedReport = $0; showDeleteConfirmation = true } : nil
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                ReportListFloatingButton(isCreatingReport: $isCreatingReport)
                    .opacity(canSubmit ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: canSubmit)
                    .allowsHitTesting(canSubmit)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ReportListToolbar(
                isFavorited: $isFavorited,
                hasLoaded: $hasLoaded,
                presentationMode: presentationMode,
                spot: spot,
                toggleFavorite: toggleFavorite
            )
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .sheet(isPresented: $isCreatingReport) {
            CreateReportView(spot: spot) {
                Task {
                    if isSearch {
                        await dataManager.fetchSearchSpotAndReports(spot: spot)
                    } else {
                        await dataManager.fetchFavoriteSpotReports(spotId: spot.id)
                    }
                    await checkIfCanSubmit()
                    await preloadUsernames()
                }
            }
        }
        .sheet(item: $selectedUserId) { identifiable in
            NavigationStack {
                UserProfileViewLoader(userId: identifiable.id)
            }
        }
        .onAppear {
            Task {
                if isSearch {
                    await dataManager.fetchSearchSpotAndReports(spot: spot)
                }
                await checkIfFavorited()
                await checkIfCanSubmit()
                await preloadUsernames()

                hasLoaded = true
            }
        }
        .onDisappear {
            dataManager.clearSearchSpot()
        }
    }

    private func preloadUsernames() async {
        let reports = isSearch ? dataManager.searchReports : dataManager.reports(for: spot.id)

        var results: [UUID: String] = [:]

        await withTaskGroup(of: (UUID, String?).self) { group in
            for report in reports {
                if results[report.user_id] == nil {
                    group.addTask {
                        let name = await UserService.shared.fetchUsername(for: report.user_id)
                        return (report.user_id, name)
                    }
                }
            }

            for await (userId, username) in group {
                if let name = username {
                    results[userId] = name
                }
            }
        }

        DispatchQueue.main.async {
            self.usernames = results
        }
    }

    private func checkIfCanSubmit() async {
        guard let userId = userSession.currentUser?.id else { return }
        do {
            let result = try await reportService.canUserSubmitReport(userId: userId)
            DispatchQueue.main.async {
                canSubmit = result
            }
        } catch {
            DispatchQueue.main.async {
                canSubmit = true
            }
        }
    }

    private func checkIfFavorited() async {
        guard let userId = userSession.currentUser?.id else { return }
        do {
            isFavorited = try await favoriteService.isSpotFavorited(byUserId: userId, spotId: spot.id)
        } catch {
            print("Error checking favorite status: \(error)")
        }
    }

    private func toggleFavorite() {
        guard let userId = userSession.currentUser?.id else { return }

        let previousState = isFavorited
        isFavorited.toggle()

        Task {
            do {
                let newState = try await favoriteService.toggleFavorite(userId: userId, spotId: spot.id)
                DispatchQueue.main.async {
                    isFavorited = newState
                }
            } catch {
                DispatchQueue.main.async {
                    isFavorited = previousState
                }
            }
        }
    }
}
