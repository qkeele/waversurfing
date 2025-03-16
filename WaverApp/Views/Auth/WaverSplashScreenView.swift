//
//  WaverSplashScreen.swift
//  Waver
//
//  Created by Quincy Keele on 3/7/25.
//

import SwiftUI

struct WaverSplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            /*Image(colorScheme == .dark ? "waverlg" : "waverlgblack")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200) // Match storyboard constraints*/
        }
    }
}
