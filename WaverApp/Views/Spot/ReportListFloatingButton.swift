//
//  ReportListFloatingButton.swift
//  Waver
//
//  Created by Quincy Keele on 3/4/25.
//

import SwiftUI

struct ReportListFloatingButton: View {
    @Binding var isCreatingReport: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isCreatingReport = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary) // ✅ Matches system text color
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color(UIColor.systemGray5)) // ✅ Softer, more native look
                                .shadow(color: Color.black.opacity(0.2), radius: 3)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
