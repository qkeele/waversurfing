//
//  ToastView.swift
//  Waver
//
//  Created by Quincy Keele on 2/26/25.
//

import SwiftUI

class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    @Published var color: Color = .green

    func showToast(message: String, color: Color = .green) {
        self.message = message
        self.color = color
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isShowing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isShowing = false
            }
        }
    }
}

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
