//
//  ExploreView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var storage: AppStorage

    @State private var selectedDifficulty: Difficulty = .easy

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose your next route")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    AppCard {
                        Text("Difficulty")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        HStack(spacing: 10) {
                            ForEach(Difficulty.allCases) { difficulty in
                                Button(difficulty.rawValue) {
                                    selectedDifficulty = difficulty
                                }
                                .buttonStyle(DifficultyButtonStyle(isSelected: selectedDifficulty == difficulty))
                            }
                        }
                    }

                    ForEach(ActivityType.allCases) { activity in
                        NavigationLink {
                            LevelSelectionView(activity: activity, difficulty: selectedDifficulty)
                        } label: {
                            AppCard {
                                HStack {
                                    Image(systemName: activity.iconSystemName)
                                        .font(.title3)
                                        .foregroundStyle(Color.appAccent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(activity.title)
                                            .font(.headline)
                                            .foregroundStyle(Color.appTextPrimary)
                                        Text(activity.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(Color.appTextSecondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Text("Stars: \(activityTotalStars(activity))/\(ActivityType.maxLevel * 3)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .appScreenBackground()
        }
    }

    private func activityTotalStars(_ activity: ActivityType) -> Int {
        (1...ActivityType.maxLevel).reduce(0) { partial, level in
            partial + storage.stars(for: activity, level: level)
        }
    }
}

private struct DifficultyButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color.appTextPrimary)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background((isSelected ? Color.appPrimary : Color.appBackground).opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct LevelSelectionView: View {
    @EnvironmentObject private var storage: AppStorage

    let activity: ActivityType
    let difficulty: Difficulty

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(activity.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)

                Text("Difficulty: \(difficulty.rawValue)")
                    .foregroundStyle(Color.appTextSecondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(1...ActivityType.maxLevel, id: \.self) { level in
                        let unlocked = level <= storage.unlockedLevel(for: activity)
                        NavigationLink {
                            ActivityPlayContainerView(
                                config: ActivitySessionConfig(activity: activity, difficulty: difficulty, level: level)
                            )
                        } label: {
                            AppCard {
                                Text("Level \(level)")
                                    .font(.headline)
                                    .foregroundStyle(unlocked ? Color.appTextPrimary : Color.appTextSecondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                if unlocked {
                                    StarRowView(stars: storage.stars(for: activity, level: level))
                                } else {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(!unlocked)
                    }
                }

                if storage.unlockedLevel(for: activity) >= ActivityType.maxLevel {
                    AppCard {
                        Text("All levels are unlocked for this route.")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .navigationTitle("Levels")
        .navigationBarTitleDisplayMode(.inline)
    }
}
