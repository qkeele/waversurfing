//
//  SpotReportListViewLoader.swift
//  Waver
//
//  Created by Sydney Del Fosse on 5/8/25.
//

import SwiftUI

struct SpotReportListViewLoader: View {
    let spotId: UUID
    @State private var spot: Spot?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let spot = spot {
                ReportListView(spot: spot)
            } else if isLoading {
                ProgressView()
            } else {
                Text("Failed to load spot")
            }
        }
        .task {
            if spot == nil {
                do {
                    spot = try await SpotService().getSpot(byId: spotId)
                } catch {
                    print("Failed to load spot:", error)
                }
                isLoading = false
            }
        }
    }
}
