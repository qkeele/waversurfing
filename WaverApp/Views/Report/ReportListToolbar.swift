//
//  ReportListToolbar.swift
//  Waver
//
//  Created by Quincy Keele on 3/4/25.
//

import SwiftUI

struct ReportListToolbar: ToolbarContent {
    @Binding var isFavorited: Bool
    @Binding var hasLoaded: Bool // ✅ New binding to track loading state
    let presentationMode: Binding<PresentationMode>
    let spot: Spot
    let toggleFavorite: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)

                Text(spot.name)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            if hasLoaded { // ✅ Only show once fully loaded
                Button(action: {
                    toggleFavorite()
                }) {
                    ZStack {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .imageScale(.medium)
                            .opacity(isFavorited ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: isFavorited)

                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .imageScale(.medium)
                            .opacity(isFavorited ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: isFavorited)
                    }
                }
            }
        }
    }
}
