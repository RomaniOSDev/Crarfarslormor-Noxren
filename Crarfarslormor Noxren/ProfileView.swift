//
//  ProfileView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var storage: AppStorage

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Travel progress")
                        .font(.title2.bold())
                        .foregroundStyle(Color.appTextPrimary)

                    AppCard {
                        statRow("Total stars", "\(storage.totalStarsCollected)")
                        statRow("Activities played", "\(storage.totalActivitiesPlayed)")
                        statRow("Total play time", storage.totalPlayTime.mmss)
                        statRow("Completed levels", "\(storage.completedLevelsCount)")
                    }

                    AppCard {
                        Text("Achievements")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        if storage.achievements.isEmpty {
                            Text("No achievements yet. Complete activities to unlock milestones.")
                                .foregroundStyle(Color.appTextSecondary)
                        } else {
                            ForEach(storage.achievements) { achievement in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundStyle(Color.appAccent)
                                    VStack(alignment: .leading, spacing: 3) {
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

                    NavigationLink {
                        SettingsView()
                    } label: {
                        HStack {
                            Text("Open Settings")
                                .foregroundStyle(Color.appTextPrimary)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .appScreenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func statRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .fontWeight(.semibold)
        }
    }
}
