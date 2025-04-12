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
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1)
                        .padding(.top, 12)
                    Spacer()
                }
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding(.top, 12)
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
                            NavigationLink(destination: UserProfileView(user: user)
                                .environmentObject(userSession)
                            ) {
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
