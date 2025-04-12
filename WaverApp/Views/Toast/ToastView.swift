//
//  ToastView.swift
//  Waver
//
//  Created by Quincy Keele on 2/26/25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let backgroundColor: Color

    var body: some View {
        VStack {
            Spacer().frame(height: 50) // Adjust position
            HStack {
                Text(message)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity) // Full-width toast
                    .background(backgroundColor)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal, 20)
        }
        .transition(.move(edge: .top).combined(with: .opacity)) // Slide & fade
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}
