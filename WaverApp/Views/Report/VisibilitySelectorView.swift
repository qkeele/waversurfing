//
//  VisibilitySelectorView.swift
//  Waver
//
//  Created by Quincy Keele on 4/12/25.
//

import Foundation
import SwiftUI

struct VisibilitySelectorView: View {
    @Binding var selectedVisibility: String?
    
    private let options: [(label: String, value: String, icon: String)] = [
        ("Public", "public", "globe"),
        ("Friends", "friends", "person.2.fill"),
        ("Private", "private", "lock.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Visibility")
                .font(.headline)
                .padding(.horizontal)

            Menu {
                ForEach(options, id: \.value) { option in
                    Button {
                        selectedVisibility = option.value
                    } label: {
                        Label(option.label, systemImage: option.icon)
                    }
                }
            } label: {
                HStack {
                    if let selected = options.first(where: { $0.value == selectedVisibility }) {
                        Label(selected.label, systemImage: selected.icon)
                            .foregroundColor(.primary)
                    } else {
                        Text("Select Visibility")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }
}
