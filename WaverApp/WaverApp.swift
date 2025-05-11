//
//  WaverApp.swift
//  Waver
//
//  Created by Quincy Keele on 2/13/25.
//
import SwiftUI
import Supabase

@main
struct WaverApp: App {
    @StateObject private var userSession = UserSession()
    @StateObject private var dataManager = SurfDataManager()
    @State private var isRegistering = false

    var body: some Scene {
        WindowGroup {
            if !userSession.isSessionLoaded {
                WaverSplashScreenView()
            } else if let _ = userSession.currentUser {
                HomeView()
                    .environmentObject(userSession)
                    .environmentObject(dataManager)
            } else {
                if isRegistering {
                    RegisterView(isRegistering: $isRegistering)
                        .environmentObject(userSession)
                } else {
                    SignInView(isRegistering: $isRegistering)
                        .environmentObject(userSession)
                }
            }
        }
    }
}
