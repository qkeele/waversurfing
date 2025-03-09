//
//  ValidationIcon.swift
//  Waver
//
//  Created by Quincy Keele on 2/23/25.
//

import SwiftUI

struct ValidationIcon: View {
    var isValid: Bool?

    var body: some View {
        Group {
            if let valid = isValid {
                Image(systemName: valid ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(valid ? .green : .red)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red.opacity(0.6))
            }
        }
    }
}
