//
//  CompeteView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct CompeteView: View {
    @State private var challenge: ActivitySessionConfig = CompeteView.makeChallenge()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly challenge")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    AppCard {
                        Text(challenge.activity.title)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Difficulty: \(challenge.difficulty.rawValue)")
                            .foregroundStyle(Color.appTextSecondary)
                        Text("Level: \(challenge.level)")
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    NavigationLink {
                        ActivityPlayContainerView(config: challenge)
                    } label: {
                        Text("Start Challenge")
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Button("Generate New Challenge") {
                        challenge = Self.makeChallenge()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .appScreenBackground()
        }
    }

    private static func makeChallenge() -> ActivitySessionConfig {
        let activity = ActivityType.allCases.randomElement() ?? .landmarkQuest
        let difficulty = Difficulty.allCases.randomElement() ?? .normal
        let level = Int.random(in: 1...ActivityType.maxLevel)
        return ActivitySessionConfig(activity: activity, difficulty: difficulty, level: level)
    }
}
