//
//  SettingsView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var storage: AppStorage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AppCard {
                    Text("Support")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    Button("Rate Us") {
                        rateApp()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Button("Privacy Policy") {
                        openPrivacyPolicy()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())

                    Button("Terms of Use") {
                        openTermsOfUse()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }

                AppCard {
                    Text("App")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    Button("Show Onboarding Again") {
                        storage.hasSeenOnboarding = false
                    }
                    .buttonStyle(SecondaryActionButtonStyle())

                    Button("Reset All Progress") {
                        storage.resetAll()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://crarfarslormor103noxren.site/privacy/17") {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: "https://crarfarslormor103noxren.site/terms/17") {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
