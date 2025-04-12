//
//  FloatingToastView.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
//

import Foundation
import SwiftUI

struct FloatingToastView: View {
    let message: String
    let backgroundColor: Color

    var body: some View {
        Text(message)
            .font(.caption2) // ✅ very small text
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(backgroundColor.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(.top, 10)
            .padding(.trailing, 10)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: message)
    }
}
