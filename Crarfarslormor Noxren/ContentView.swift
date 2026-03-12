//
//  ContentView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage = AppStorage()

    var body: some View {
        Group {
            if storage.hasSeenOnboarding {
                MainTabContainerView()
            } else {
                OnboardingView {
                    storage.hasSeenOnboarding = true
                }
            }
        }
        .environmentObject(storage)
        .appScreenBackground()
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
