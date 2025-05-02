//
//  ContactSheet.swift
//  Waver
//
//  Created by Quincy Keele on 4/12/25.
//

import Foundation
import SwiftUI

struct ContactSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            HStack(spacing: 8) {
                Text("Contact")
                    .font(.title2)
                    .bold()

                Image(colorScheme == .dark ? "waver_logo" : "waver_logo_black")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18) // adjust size to match text baseline
            }
            Text("For feedback, support, or inquiries reach out at:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("waversurfing@gmail.com")
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            Button(action: { dismiss() }) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.fraction(0.3)])
    }
}
