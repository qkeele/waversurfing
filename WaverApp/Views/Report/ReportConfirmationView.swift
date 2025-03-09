//
//  ReportConfirmationView.swift
//  Waver
//
//  Created by Quincy Keele on 3/7/25.
//

import SwiftUI

struct ReportConfirmationView: View {
    var onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme // ✅ Detect system theme

    var body: some View {
        ZStack {
            // ✅ Uses system background color
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.green)

                Text("Report submitted!")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding()
        }
    }
}
