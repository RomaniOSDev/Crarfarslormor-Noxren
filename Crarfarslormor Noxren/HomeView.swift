//
//  HomeView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorage

    @State private var selectedDifficulty: Difficulty = .normal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerCard
                    quickStartCard
                    difficultyCard
                    activitiesSection
                    achievementsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .appScreenBackground()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerCard: some View {
        AppCard {
            Text("Your global route")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Track progress, start a new challenge, and improve your stars.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total stars")
                        .foregroundStyle(Color.appTextSecondary)
                    Spacer()
                    Text("\(storage.totalStarsCollected)/\(ActivityType.allCases.count * ActivityType.maxLevel * 3)")
                        .foregroundStyle(Color.appTextPrimary)
                        .fontWeight(.semibold)
                }
                ProgressView(value: progressValue)
                    .tint(Color.appAccent)
                HStack {
                    statBadge(title: "Played", value: "\(storage.totalActivitiesPlayed)")
                    statBadge(title: "Time", value: storage.totalPlayTime.mmss)
                    statBadge(title: "Levels", value: "\(storage.completedLevelsCount)")
                }
            }
        }
    }

    private var quickStartCard: some View {
        AppCard {
            Text("Quick start")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            Text("Continue from the next available level in each activity.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

            ForEach(ActivityType.allCases) { activity in
                let nextLevel = min(storage.unlockedLevel(for: activity), ActivityType.maxLevel)
                NavigationLink {
                    ActivityPlayContainerView(
                        config: ActivitySessionConfig(
                            activity: activity,
                            difficulty: selectedDifficulty,
                            level: nextLevel
                        )
                    )
                } label: {
                    HStack {
                        Image(systemName: activity.iconSystemName)
                            .foregroundStyle(Color.appAccent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.title)
                                .foregroundStyle(Color.appTextPrimary)
                                .font(.subheadline.weight(.semibold))
                            Text("Level \(nextLevel) • \(selectedDifficulty.rawValue)")
                                .foregroundStyle(Color.appTextSecondary)
                                .font(.caption)
                        }
                        Spacer()
                        Image(systemName: "play.fill")
                            .foregroundStyle(Color.appPrimary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .padding(.vertical, 2)
            }
        }
    }

    private var difficultyCard: some View {
        AppCard {
            Text("Default difficulty")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 10) {
                ForEach(Difficulty.allCases) { difficulty in
                    Button(difficulty.rawValue) {
                        selectedDifficulty = difficulty
                    }
                    .buttonStyle(HomeDifficultyStyle(isSelected: selectedDifficulty == difficulty))
                }
            }
        }
    }

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Activities")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            ForEach(ActivityType.allCases) { activity in
                AppCard {
                    HStack {
                        Image(systemName: activity.iconSystemName)
                            .font(.title3)
                            .foregroundStyle(Color.appAccent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.title)
                                .foregroundStyle(Color.appTextPrimary)
                                .font(.headline)
                            Text(activity.subtitle)
                                .foregroundStyle(Color.appTextSecondary)
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    Text("Collected stars: \(starsForActivity(activity))/\(ActivityType.maxLevel * 3)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent milestones")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            AppCard {
                if storage.achievements.isEmpty {
                    Text("No milestones yet. Complete routes to unlock achievements.")
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    ForEach(Array(storage.achievements.prefix(3))) { achievement in
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(Color.appAccent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(achievement.title)
                                    .foregroundStyle(Color.appTextPrimary)
                                    .font(.subheadline.weight(.semibold))
                                Text(achievement.detail)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
    }

    private func statBadge(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.appBackground.opacity(0.95), Color.appSurface.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.appAccent.opacity(0.18), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var progressValue: Double {
        let maxStars = Double(ActivityType.allCases.count * ActivityType.maxLevel * 3)
        guard maxStars > 0 else { return 0 }
        return min(1, Double(storage.totalStarsCollected) / maxStars)
    }

    private func starsForActivity(_ activity: ActivityType) -> Int {
        (1...ActivityType.maxLevel).reduce(0) { partial, level in
            partial + storage.stars(for: activity, level: level)
        }
    }
}

private struct HomeDifficultyStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                LinearGradient(
                    colors: isSelected
                        ? [Color.appPrimary.opacity(configuration.isPressed ? 0.82 : 1), Color.appAccent.opacity(0.85)]
                        : [Color.appBackground.opacity(0.95), Color.appSurface.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
