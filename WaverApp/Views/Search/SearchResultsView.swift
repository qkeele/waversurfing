//
//  SearchResultsView.swift
//  Waver
//
//  Created by Quincy Keele on 4/7/25.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var viewModel: SearchResultsViewModel
    @EnvironmentObject var dataManager: SurfDataManager

    var body: some View {
        VStack {
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .padding()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.spotResults.isEmpty && viewModel.userResults.isEmpty {
                Text("No results")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    if viewModel.searchType == .spots {
                        ForEach(viewModel.spotResults) { spot in
                            NavigationLink(destination: ReportListView(spot: spot, dataManager: dataManager)) {
                                Text(spot.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowSeparator(.hidden)
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    } else {
                        ForEach(viewModel.userResults, id: \.id) { user in
                            NavigationLink(destination: UserProfileView(user: user)) {
                                Text(user.username)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .listRowSeparator(.hidden)
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
