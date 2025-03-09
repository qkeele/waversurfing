//  SearchView.swift
//  Waver
//
//  Created by Quincy Keele on 2/17/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: SurfDataManager

    let regions = regionTree  // Your top-level region array

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ✅ Top Bar (Title + Close Button)
                HStack {
                    Text("Find a Spot")
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    // ❌ Close Button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                // ✅ Region List View
                RegionListView(
                    nodes: regions,
                    path: []
                )
                .environmentObject(dataManager)
            }
            .navigationBarHidden(true) // ✅ Completely hides default navigation bar
        }
    }
}

