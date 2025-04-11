//
//  SearchView.swift
//  Waver
//
//  Created by Quincy Keele on 2/17/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: SurfDataManager
    @StateObject private var viewModel = SearchResultsViewModel()

    let regions = regionTree

    @FocusState private var isFocusedOnSearch: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Top Bar
                HStack {
                    Text("Find a Spot")
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                // MARK: - Search Bar & Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search", text: $viewModel.searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isFocusedOnSearch)

                        if isFocusedOnSearch || !viewModel.searchText.isEmpty {
                            Button(action: {
                                withAnimation {
                                    viewModel.searchText = ""
                                    isFocusedOnSearch = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                    if isFocusedOnSearch || !viewModel.searchText.isEmpty {
                        Picker("Search Type", selection: $viewModel.searchType) {
                            ForEach(SearchType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .transition(.opacity)
                        .padding(.horizontal)

                        SearchResultsView(viewModel: viewModel)
                    } else {
                        RegionListView(nodes: regions, path: [])
                            .environmentObject(dataManager)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
        }
    }
}
