//
//  ReportConfirmationView.swift
//  Waver
//
//  Created by Quincy Keele on 3/7/25.
//

import SwiftUI

struct ReportConfirmationView: View {
    var onDismiss: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                    .padding([.top, .trailing])
                }

                Spacer()

                // Main content, styled like RegistrationConfirmationView
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)

                    Text("Report submitted!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                }

                Spacer()
            }
        }
    }
}
