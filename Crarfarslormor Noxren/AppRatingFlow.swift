//
//  AppRatingFlow.swift
//  Crarfarslormor Noxren
//
//  Device: SKStoreReviewController on a foreground/key UIWindowScene (not `connectedScenes.first`).
//  Simulator: system in-app rating is unreliable — open App Store “write review” via iTunes lookup by bundle id.
//

import Foundation
import StoreKit
import UIKit

enum AppRatingFlow {
    /// Scene that hosts the foreground UI — `connectedScenes.first` order is undefined (iPad / multi-window).
    @MainActor
    static func preferredWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let match = scenes.first(where: { $0.activationState == .foregroundActive }) {
            return match
        }
        if let match = scenes.first(where: { scene in
            scene.windows.contains { $0.isKeyWindow }
        }) {
            return match
        }
        return scenes.first
    }

    /// Call from a button. Pass StoreKit’s `requestReview` closure as fallback when no window scene exists.
    @MainActor
    static func requestRatingFromUserTap(swiftUIRequestReview: @escaping () -> Void) {
        Task { @MainActor in
            await Task.yield()
            #if targetEnvironment(simulator)
            await openWriteReviewInAppStoreOrFallback(swiftUIRequestReview: swiftUIRequestReview)
            #else
            if let scene = preferredWindowScene() {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                swiftUIRequestReview()
            }
            #endif
        }
    }

    // MARK: - Simulator: App Store review page

    private struct ITunesLookupResponse: Decodable {
        let resultCount: Int
        let results: [Track]
        struct Track: Decodable {
            let trackId: Int
        }
    }

    @MainActor
    private static func openWriteReviewInAppStoreOrFallback(swiftUIRequestReview: @escaping () -> Void) async {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            swiftUIRequestReview()
            return
        }
        var components = URLComponents(string: "https://itunes.apple.com/lookup")!
        components.queryItems = [URLQueryItem(name: "bundleId", value: bundleId)]
        guard let lookupURL = components.url else {
            swiftUIRequestReview()
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: lookupURL)
            guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
                swiftUIRequestReview()
                return
            }
            let decoded = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
            guard decoded.resultCount > 0, let id = decoded.results.first?.trackId else {
                swiftUIRequestReview()
                return
            }
            let reviewURLString = "https://apps.apple.com/app/id\(id)?action=write-review"
            guard let reviewURL = URL(string: reviewURLString) else {
                swiftUIRequestReview()
                return
            }
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        } catch {
            swiftUIRequestReview()
        }
    }
}
