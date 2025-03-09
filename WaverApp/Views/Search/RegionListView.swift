//  RegionListView.swift
//  Waver
//
//  Created by Quincy Keele on 2/17/25.
//

import SwiftUI

struct RegionListView: View {
    let nodes: [RegionNode]
    let path: [String]
    
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataManager: SurfDataManager

    var body: some View {
        List {
            ForEach(nodes) { node in
                if node.children.isEmpty {
                    // Terminal node - open new page with spots
                    NavigationLink {
                        SpotListView(regionPath: path + [node.name])
                            .environmentObject(dataManager)
                    } label: {
                        Text(node.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowSeparator(.hidden)
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                } else {
                    // Navigate deeper into regions
                    NavigationLink {
                        RegionListView(
                            nodes: node.children,
                            path: path + [node.name]
                        )
                    } label: {
                        Text(node.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowSeparator(.hidden)
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
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
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)

                    if let currentLevel = path.last {
                        Text(currentLevel)
                            .font(.headline)
                    }
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
    }
}
