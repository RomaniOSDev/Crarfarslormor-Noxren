//
//  AppStorage.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import Foundation
import Combine

extension Notification.Name {
    static let didResetProgress = Notification.Name("didResetProgress")
}

final class AppStorage: ObservableObject {
    private let defaults: UserDefaults

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published private(set) var totalPlayTime: TimeInterval {
        didSet { defaults.set(totalPlayTime, forKey: Keys.totalPlayTime) }
    }

    @Published private(set) var totalActivitiesPlayed: Int {
        didSet { defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published private(set) var starsByLevel: [String: Int] {
        didSet { defaults.set(starsByLevel, forKey: Keys.starsByLevel) }
    }

    @Published private(set) var unlockedByActivity: [String: Int] {
        didSet { defaults.set(unlockedByActivity, forKey: Keys.unlockedByActivity) }
    }

    struct CompletionOutcome {
        let unlockedNewLevel: Bool
        let newAchievements: [Achievement]
    }

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalPlayTime = "totalPlayTime"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let starsByLevel = "starsByLevel"
        static let unlockedByActivity = "unlockedByActivity"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        self.totalPlayTime = defaults.double(forKey: Keys.totalPlayTime)
        self.totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        self.starsByLevel = defaults.dictionary(forKey: Keys.starsByLevel) as? [String: Int] ?? [:]
        self.unlockedByActivity = defaults.dictionary(forKey: Keys.unlockedByActivity) as? [String: Int] ?? [:]

        for activity in ActivityType.allCases {
            if unlockedByActivity[activity.rawValue] == nil {
                unlockedByActivity[activity.rawValue] = 1
            }
        }
    }

    func stars(for activity: ActivityType, level: Int) -> Int {
        let key = levelKey(activity: activity, level: level)
        return starsByLevel[key] ?? 0
    }

    func unlockedLevel(for activity: ActivityType) -> Int {
        max(1, unlockedByActivity[activity.rawValue] ?? 1)
    }

    func completeLevel(
        activity: ActivityType,
        level: Int,
        stars: Int,
        duration: TimeInterval
    ) -> CompletionOutcome {
        let before = Set(achievements.map(\.id))
        let key = levelKey(activity: activity, level: level)
        let safeStars = min(max(stars, 1), 3)
        let oldStars = starsByLevel[key] ?? 0
        starsByLevel[key] = max(oldStars, safeStars)

        totalActivitiesPlayed += 1
        totalPlayTime += max(duration, 0)

        let previousUnlocked = unlockedLevel(for: activity)
        if safeStars > 0 {
            let candidate = min(ActivityType.maxLevel, level + 1)
            unlockedByActivity[activity.rawValue] = max(previousUnlocked, candidate)
        }

        let afterAchievements = achievements
        let newAchievements = afterAchievements.filter { !before.contains($0.id) }
        return CompletionOutcome(
            unlockedNewLevel: unlockedLevel(for: activity) > previousUnlocked,
            newAchievements: newAchievements
        )
    }

    var totalStarsCollected: Int {
        starsByLevel.values.reduce(0, +)
    }

    var completedLevelsCount: Int {
        starsByLevel.values.filter { $0 > 0 }.count
    }

    var fullyCompletedLevelsCount: Int {
        starsByLevel.values.filter { $0 == 3 }.count
    }

    var allLevelsCompleted: Bool {
        ActivityType.allCases.allSatisfy { unlockedLevel(for: $0) >= ActivityType.maxLevel }
    }

    var achievements: [Achievement] {
        var list: [Achievement] = []

        if completedLevelsCount >= 3 {
            list.append(Achievement(
                id: "first_routes",
                title: "First Routes",
                detail: "Complete at least 3 levels."
            ))
        }
        if totalStarsCollected >= 24 {
            list.append(Achievement(
                id: "star_collector",
                title: "Star Collector",
                detail: "Collect 24 stars across activities."
            ))
        }
        if totalPlayTime >= 900 {
            list.append(Achievement(
                id: "time_explorer",
                title: "Time Explorer",
                detail: "Play for 15 minutes in total."
            ))
        }
        if fullyCompletedLevelsCount >= 12 {
            list.append(Achievement(
                id: "precision_traveler",
                title: "Precision Traveler",
                detail: "Earn 3 stars in 12 levels."
            ))
        }
        if ActivityType.allCases.allSatisfy({ unlockedLevel(for: $0) >= ActivityType.maxLevel }) {
            list.append(Achievement(
                id: "global_pathfinder",
                title: "Global Pathfinder",
                detail: "Unlock all levels in every activity."
            ))
        }

        return list
    }

    func resetAll() {
        defaults.removeObject(forKey: Keys.hasSeenOnboarding)
        defaults.removeObject(forKey: Keys.totalPlayTime)
        defaults.removeObject(forKey: Keys.totalActivitiesPlayed)
        defaults.removeObject(forKey: Keys.starsByLevel)
        defaults.removeObject(forKey: Keys.unlockedByActivity)

        hasSeenOnboarding = false
        totalPlayTime = 0
        totalActivitiesPlayed = 0
        starsByLevel = [:]
        unlockedByActivity = ActivityType.allCases.reduce(into: [:]) { partial, activity in
            partial[activity.rawValue] = 1
        }

        NotificationCenter.default.post(name: .didResetProgress, object: nil)
    }

    private func levelKey(activity: ActivityType, level: Int) -> String {
        "\(activity.rawValue)_\(level)"
    }
}
