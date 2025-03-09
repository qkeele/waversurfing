//
//  SurfDataManager.swift
//  Waver
//
//  Created by Quincy Keele on 2/19/25.
//

import Foundation
import SwiftUI

class SurfDataManager: ObservableObject {
    @Published var spots: [Spot] = [] // ✅ Favorite spots
    @Published var reportsBySpot: [UUID: [Report]] = [:] // ✅ Reports for favorite spots
    @Published var isLoadingReports = true

    // ✅ Search Spot (NEW)
    @Published var searchSpot: Spot? = nil
    @Published var searchReports: [Report] = []
    @Published var isLoadingSearchReports = false

    private let favoriteService = FavoriteService()
    private let spotService = SpotService()
    private let reportService = ReportService()
    
    private var fetchTask: Task<Void, Never>?

    // MARK: - Favorite Spots & Reports
    @MainActor
    func fetchFavoriteSpotsAndReports(userSession: UserSession) async {
        fetchTask?.cancel()
        fetchTask = Task {
            self.isLoadingReports = true
            
            guard let userId = userSession.currentUser?.id else { return }
            
            do {
                let favorites = try await favoriteService.fetchFavorites(forUserId: userId)
                let spotIds = favorites.map { $0.spot_id }
                let fetchedSpots = try await spotService.getSpotsByIds(spotIds)
                
                DispatchQueue.main.async {
                    self.spots = fetchedSpots
                }
                
                var newReportsBySpot: [UUID: [Report]] = [:]
                
                await withTaskGroup(of: (UUID, [Report]).self) { group in
                    for spot in fetchedSpots {
                        group.addTask {
                            let reports = (try? await self.reportService.fetchReportsForSpotToday(spotId: spot.id)) ?? []
                            return (spot.id, reports.sorted { $0.timestamp > $1.timestamp })
                        }
                    }
                    
                    for await (spotId, reports) in group {
                        newReportsBySpot[spotId] = reports
                    }
                }
                
                DispatchQueue.main.async {
                    self.reportsBySpot = newReportsBySpot
                    self.isLoadingReports = false
                }
                
            } catch {
                print("Error fetching favorite spots and reports: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingReports = false
                }
            }
        }
    }
    
    @MainActor
    func fetchFavoriteSpotReports(spotId: UUID) async {
        do {
            let reports = try await reportService.fetchReportsForSpotToday(spotId: spotId)
            DispatchQueue.main.async {
                self.reportsBySpot[spotId] = reports.sorted { $0.timestamp > $1.timestamp }
            }
        } catch {
            print("Error fetching reports for spot \(spotId): \(error)")
        }
    }

    // ✅ Get reports for a specific spot (favorites)
    func reports(for spotID: UUID) -> [Report] {
        return reportsBySpot[spotID] ?? []
    }

    // MARK: - 🔹 Search Spot & Reports
    @MainActor
    func fetchSearchSpotAndReports(spot: Spot) async {
        self.searchSpot = spot
        self.isLoadingSearchReports = true

        do {
            let fetchedReports = try await reportService.fetchReportsForSpotToday(spotId: spot.id)
            DispatchQueue.main.async {
                self.searchReports = fetchedReports.sorted { $0.timestamp > $1.timestamp }
                self.isLoadingSearchReports = false
            }
        } catch {
            print("Error fetching search spot reports: \(error)")
            DispatchQueue.main.async {
                self.isLoadingSearchReports = false
            }
        }
    }

    func clearSearchSpot() {
        self.searchSpot = nil
        self.searchReports = []
        self.isLoadingSearchReports = false
    }

    // MARK: - Computations (Used for Both Favorites & Search)
    func distribution(for spotID: UUID, isSearch: Bool = false) -> RatingDistribution {
        let spotReports = isSearch ? searchReports : reports(for: spotID)
        var rating0 = 0, rating1 = 0, rating2 = 0, rating3 = 0

        for r in spotReports {
            switch r.rating {
            case 0: rating0 += 1
            case 1: rating1 += 1
            case 2: rating2 += 1
            case 3: rating3 += 1
            default: break
            }
        }

        return RatingDistribution(
            rating0Count: rating0,
            rating1Count: rating1,
            rating2Count: rating2,
            rating3Count: rating3
        )
    }

    func averageHeight(for spotID: UUID, isSearch: Bool = false) -> Double {
        let spotReports = isSearch ? searchReports : reports(for: spotID)
        guard !spotReports.isEmpty else { return 0 }

        let total = spotReports.reduce(0) { $0 + $1.height }
        return Double(total) / Double(spotReports.count)
    }

    func averageCrowd(for spotID: UUID, isSearch: Bool = false) -> Double {
        let spotReports = isSearch ? searchReports : reports(for: spotID)
        guard !spotReports.isEmpty else { return 0 }

        let total = spotReports.reduce(0) { $0 + $1.crowd }
        return Double(total) / Double(spotReports.count)
    }
}

