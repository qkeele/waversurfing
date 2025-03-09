//
//  ReportListView.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import SwiftUI

struct ReportListView: View {
    let spot: Spot
    @ObservedObject var dataManager: SurfDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isFavorited = false
    @State private var isCreatingReport = false
    @State private var canSubmit = false
    @State private var hasLoaded = false
    @StateObject private var favoriteService = FavoriteService()
    @StateObject private var reportService = ReportService()
    @EnvironmentObject var userSession: UserSession

    private var isSearch: Bool {
        !dataManager.spots.contains(where: { $0.id == spot.id })
    }

    var body: some View {
        ZStack {
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
                            isLoading: isSearch ? dataManager.isLoadingSearchReports : dataManager.isLoadingReports
                        )
                        .padding()

                        ForEach(reports) { report in
                            ReportView(report: report)
                                .padding(.horizontal)
                                .environmentObject(userSession)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            ReportListFloatingButton(isCreatingReport: $isCreatingReport)
                .opacity(canSubmit ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: canSubmit)
                .allowsHitTesting(canSubmit) // Prevent interaction when hidden

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ReportListToolbar(
                isFavorited: $isFavorited,
                hasLoaded: $hasLoaded, // ✅ Pass loading state
                presentationMode: presentationMode,
                spot: spot,
                toggleFavorite: toggleFavorite
            )
        }
        .onAppear {
            Task {
                await checkIfFavorited()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // ✅ Prevents flicker
                    hasLoaded = true
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .sheet(isPresented: $isCreatingReport) {
            CreateReportView(spot: spot) {
                Task {
                    if isSearch {
                        await dataManager.fetchSearchSpotAndReports(spot: spot)
                    } else {
                        await dataManager.fetchFavoriteSpotReports(spotId: spot.id) // ✅ Fetch reports for only this spot
                    }
                    await checkIfCanSubmit()
                }
            }
        }
        .onAppear {
            Task {
                if isSearch {
                    await dataManager.fetchSearchSpotAndReports(spot: spot)
                }
                await checkIfFavorited()
                await checkIfCanSubmit()
            }
        }
        .onDisappear {
            dataManager.clearSearchSpot()
        }
    }
    
    private func checkIfCanSubmit() async {
        guard let userId = userSession.currentUser?.id else { return }
        do {
            let result = try await reportService.canUserSubmitReport(userId: userId)
            DispatchQueue.main.async {
                canSubmit = result // ✅ Ensure UI updates
            }
        } catch {
            print("Error checking report submission time: \(error)")
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) { // ✅ Animate fallback state
                    canSubmit = true
                }
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
        isFavorited.toggle() // ✅ Instantly update the UI
        
        Task {
            do {
                let newState = try await favoriteService.toggleFavorite(userId: userId, spotId: spot.id)
                DispatchQueue.main.async {
                    isFavorited = newState
                }
            } catch {
                print("Error toggling favorite: \(error)")
                DispatchQueue.main.async {
                    isFavorited = previousState // ❌ Revert UI if API fails
                }
            }
        }
    }
}
