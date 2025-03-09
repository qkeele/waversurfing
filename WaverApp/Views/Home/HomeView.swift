//
//  HomeView.swift
//  Waver
//
//  Created by Quincy Keele on 2/18/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var dataManager = SurfDataManager()
    @State private var isSearchPresented = false
    @State private var isProfilePresented = false
    @State private var sidebarOffset: CGFloat = -UIScreen.main.bounds.width * 0.75
    
    // ✅ Immediately create placeholder spots based on the number of favorites
    private var placeholderSpots: [Spot] {
        let count = max(dataManager.spots.count, 5) // Use real count or default to 5
        return (0..<count).map { index in
            Spot(id: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", index))") ?? UUID(),
                 name: "Loading...",
                 region: "",
                 sub_region: "",
                 sub_sub_region: "")
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("Your Spots")
                            .font(.largeTitle).bold()
                        
                        Spacer()
                        
                        Button {
                            isProfilePresented.toggle()
                        } label: {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(.primary)
                                .imageScale(.small)
                        }
                        
                        Button {
                            isSearchPresented.toggle()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.primary)
                                .imageScale(.small)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            if dataManager.isLoadingReports {
                                // ✅ Show placeholders while loading
                                ForEach(placeholderSpots) { spot in
                                    SpotViewSimple(
                                        spot: spot,
                                        distribution: RatingDistribution(rating0Count: 0, rating1Count: 0, rating2Count: 0, rating3Count: 0),
                                        averageHeight: 0,
                                        totalReports: 0
                                    )
                                    .redacted(reason: .placeholder) // ✅ Loading effect
                                    .padding(.horizontal)
                                }
                            } else if dataManager.spots.isEmpty {
                                // ✅ Show message if no favorites exist
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass.circle.fill") // Optional icon
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    
                                    Text("Tap the search icon to start finding spots")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                .frame(maxWidth: .infinity, minHeight: 300) // ✅ Center it visually
                            } else {
                                // ✅ Fill with real data when available
                                ForEach(dataManager.spots) { spot in
                                    NavigationLink(destination: ReportListView(spot: spot, dataManager: dataManager)) {
                                        SpotViewSimple(
                                            spot: spot,
                                            distribution: dataManager.distribution(for: spot.id),
                                            averageHeight: dataManager.averageHeight(for: spot.id),
                                            totalReports: dataManager.reports(for: spot.id).count
                                        )
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .transition(.opacity.combined(with: .scale)) // ✅ Smooth fade-in
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await refreshFavorites()
                    }

                }
                .sheet(isPresented: $isSearchPresented) {
                    SearchView()
                        .environmentObject(dataManager)
                }
                .sheet(isPresented: $isProfilePresented) {
                    ProfileView(dataManager: dataManager)
                        .environmentObject(userSession)
                }
                .onAppear {
                    Task {
                        await refreshFavorites()
                    }
                }
            }
        }
    }
    
    private func refreshFavorites() async {
        await dataManager.fetchFavoriteSpotsAndReports(userSession: userSession)
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.4)) { } // ✅ Ensures smooth update
        }
    }
}
