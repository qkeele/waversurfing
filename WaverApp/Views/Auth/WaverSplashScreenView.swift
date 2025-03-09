//
//  WaverSplashScreen.swift
//  Waver
//
//  Created by Quincy Keele on 3/7/25.
//

import SwiftUI

struct WaverSplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("waverlg")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 30)

            Spacer()

            /*ProgressView() // ✅ Shows loading indicator
                .progressViewStyle(CircularProgressViewStyle())
                .padding()*/
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground)) // ✅ Matches system theme
    }
}
