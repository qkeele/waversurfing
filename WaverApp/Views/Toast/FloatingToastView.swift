//
//  FloatingToastView.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import SwiftUI

struct FloatingToastView: View {
    let message: String
    let backgroundColor: Color

    var body: some View {
        Text(message)
            .font(.caption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.95))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            .transition(.move(edge: .trailing).combined(with: .opacity)) // ✅ slide in from right
            .animation(.easeInOut, value: message)
    }
}
