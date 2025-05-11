//
//  SpotListView.swift
//  Waver
//
//  Created by Quincy Keele on 2/21/25.
//

import SwiftUI

struct SpotListView: View {
    let regionPath: [String]
    
    @StateObject private var spotService = SpotService()
    @EnvironmentObject var dataManager: SurfDataManager // ✅ Use EnvironmentObject
    @State private var spots: [Spot] = []
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        VStack {
            if isLoading {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            } else {
                List {
                    ForEach(spots) { spot in
                        NavigationLink(destination: ReportListView(spot: spot)) {
                            Text(spot.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .listRowSeparator(.hidden)
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear {
            fetchSpots()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Back button with region name
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body) // ✅ Normal size
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)

                    if let currentLevel = regionPath.last {
                        Text(currentLevel)
                            .font(.headline)
                    }
                }
            }

            // X button on the right (only at root level)
            if regionPath.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
    }

    private func fetchSpots() {
        let region = regionPath.first ?? ""
        let subRegion = regionPath.count > 1 ? regionPath[1] : nil
        let subSubRegion = regionPath.count > 2 ? regionPath[2] : nil
        
        spotService.getSpots(
            region: region,
            subRegion: subRegion,
            subSubRegion: subSubRegion
        ) { fetchedSpots in
            DispatchQueue.main.async {
                self.spots = fetchedSpots
                self.isLoading = false
            }
        }
    }
}
