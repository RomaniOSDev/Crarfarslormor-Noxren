//
//  ActivityPlayContainerView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct ActivityPlayContainerView: View {
    @EnvironmentObject private var storage: AppStorage
    @Environment(\.dismiss) private var dismiss

    let config: ActivitySessionConfig

    @State private var currentLevel: Int = 1
    @State private var showResult = false
    @State private var resultStars = 1
    @State private var resultTime: TimeInterval = 0
    @State private var resultSummary = ""
    @State private var unlockedNewLevel = false
    @State private var newAchievementTitle: String?
    @State private var refreshID = UUID()

    var body: some View {
        Group {
            if showResult {
                ActivityResultView(
                    stars: resultStars,
                    duration: resultTime,
                    summary: resultSummary,
                    unlockedNewLevel: unlockedNewLevel,
                    achievementTitle: newAchievementTitle,
                    canGoNext: currentLevel < ActivityType.maxLevel
                ) {
                    if currentLevel < ActivityType.maxLevel {
                        currentLevel += 1
                        refreshID = UUID()
                        showResult = false
                    }
                } onRetry: {
                    refreshID = UUID()
                    showResult = false
                } onBackToLevels: {
                    dismiss()
                }
            } else {
                activityView
                    .id(refreshID)
            }
        }
        .onAppear {
            currentLevel = config.level
        }
        .navigationTitle("Level \(currentLevel)")
        .navigationBarTitleDisplayMode(.inline)
        .appScreenBackground()
    }

    @ViewBuilder
    private var activityView: some View {
        switch config.activity {
        case .landmarkQuest:
            LandmarkQuestView(level: currentLevel, difficulty: config.difficulty) { completion in
                complete(completion)
            }
        case .culturalCuisine:
            CulturalCuisineView(level: currentLevel, difficulty: config.difficulty) { completion in
                complete(completion)
            }
        case .traditionTrot:
            TraditionTrotView(level: currentLevel, difficulty: config.difficulty) { completion in
                complete(completion)
            }
        }
    }

    private func complete(_ completion: ActivityCompletion) {
        let outcome = storage.completeLevel(
            activity: config.activity,
            level: currentLevel,
            stars: completion.stars,
            duration: completion.duration
        )
        resultStars = completion.stars
        resultTime = completion.duration
        resultSummary = completion.summary
        unlockedNewLevel = outcome.unlockedNewLevel
        newAchievementTitle = outcome.newAchievements.first?.title
        showResult = true
    }
}
