//
//  OneSignalBootstrap.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 06.04.2026.
//

import Foundation
import UIKit
import UserNotifications

#if canImport(OneSignalFramework)
import OneSignalFramework
#endif

enum OneSignalBootstrap {
    private static let pushPromptRequestedKey = "onesignal_push_prompt_requested_v1"
    private static let tag = "[OneSignal]"

    private static func appIdFromBundle() -> String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "OneSignalAppID") as? String else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func configureIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        #if canImport(OneSignalFramework)
        guard let appId = appIdFromBundle() else { return }
        OneSignal.initialize(appId, withLaunchOptions: launchOptions)
        #endif
    }

    /// Call after installation UUID is known (same value as query param).
    static func loginExternalUserIfConfigured(externalId: String) {
        #if canImport(OneSignalFramework)
        guard appIdFromBundle() != nil else { return }
        OneSignal.login(externalId)
        #endif
    }

    /// Requests push permission once and registers for APNs.
    /// Re-login can be performed by caller in completion to stabilize identity binding.
    static func requestPushPermissionIfNeeded(completion: @escaping () -> Void = {}) {
        guard appIdFromBundle() != nil else {
            completion()
            return
        }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("\(tag) push permission current status: \(permissionStatusDescription(settings.authorizationStatus))")
        }

        if UserDefaults.standard.bool(forKey: pushPromptRequestedKey) {
            print("\(tag) push prompt already requested earlier, skipping system prompt")
            completion()
            return
        }

        UserDefaults.standard.set(true, forKey: pushPromptRequestedKey)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error {
                    print("\(tag) push permission request error: \(error.localizedDescription)")
                } else {
                    print("\(tag) push permission request result: granted=\(granted)")
                }
                UIApplication.shared.registerForRemoteNotifications()
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    print("\(tag) push permission updated status: \(permissionStatusDescription(settings.authorizationStatus))")
                }
                completion()
            }
        }
    }

    private static func permissionStatusDescription(_ status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .provisional: return "provisional"
        case .ephemeral: return "ephemeral"
        @unknown default: return "unknown"
        }
    }
}
