//
//  ActivityResultView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct ActivityResultView: View {
    let stars: Int
    let duration: TimeInterval
    let summary: String
    let unlockedNewLevel: Bool
    let achievementTitle: String?
    let canGoNext: Bool
    let onNext: () -> Void
    let onRetry: () -> Void
    let onBackToLevels: () -> Void

    @State private var visibleStars = 0
    @State private var showBanner = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let achievementTitle, showBanner {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("New milestone: \(achievementTitle)")
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                AppCard {
                    Text("Great progress")
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)
                    HStack(spacing: 14) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < visibleStars ? "star.fill" : "star")
                                .font(.system(size: 36))
                                .foregroundStyle(index < visibleStars ? Color.appAccent : Color.appTextSecondary)
                                .shadow(color: index < visibleStars ? Color.appAccent.opacity(0.8) : .clear, radius: 12)
                                .scaleEffect(index < visibleStars ? 1 : 0.75)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: visibleStars)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                AppCard {
                    stat("Completion time", duration.mmss)
                    stat("Stars earned", "\(stars)")
                    stat("Unlocked", unlockedNewLevel ? "New level available" : "No new unlock")
                    Text(summary)
                        .foregroundStyle(Color.appTextSecondary)
                }

                if canGoNext {
                    Button("Next Level", action: onNext)
                        .buttonStyle(PrimaryActionButtonStyle())
                }
                Button("Retry", action: onRetry)
                    .buttonStyle(SecondaryActionButtonStyle())
                Button("Back to Levels", action: onBackToLevels)
                    .buttonStyle(SecondaryActionButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .onAppear {
            visibleStars = 0
            for index in 0..<stars {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.15)) {
                    visibleStars = index + 1
                }
            }
            if achievementTitle != nil {
                withAnimation(.easeInOut(duration: 0.4).delay(0.15)) {
                    showBanner = true
                }
            }
        }
    }

    private func stat(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(Color.appTextPrimary)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
