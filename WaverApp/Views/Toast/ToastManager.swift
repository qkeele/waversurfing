//
//  File.swift
//  Waver
//
//  Created by Quincy Keele on 4/11/25.
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
