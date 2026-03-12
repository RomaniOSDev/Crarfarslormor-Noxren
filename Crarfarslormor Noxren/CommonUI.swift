//
//  CommonUI.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct AppScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.appBackground,
                            Color.appSurface.opacity(0.85),
                            Color.appBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    RadialGradient(
                        colors: [Color.appAccent.opacity(0.16), Color.clear],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 420
                    )
                    .ignoresSafeArea()

                    RadialGradient(
                        colors: [Color.appPrimary.opacity(0.12), Color.clear],
                        center: .bottomLeading,
                        startRadius: 10,
                        endRadius: 380
                    )
                    .ignoresSafeArea()
                }
            }
    }
}

extension View {
    func appScreenBackground() -> some View {
        modifier(AppScreenBackground())
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                LinearGradient(
                    colors: [
                        Color.appPrimary.opacity(configuration.isPressed ? 0.82 : 1),
                        Color.appAccent.opacity(configuration.isPressed ? 0.72 : 0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.appTextPrimary.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: Color.appPrimary.opacity(0.28), radius: 12, x: 0, y: 8)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.appTextPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(configuration.isPressed ? 0.75 : 0.95),
                        Color.appBackground.opacity(configuration.isPressed ? 0.82 : 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.appAccent.opacity(0.45), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct StarRowView: View {
    let stars: Int
    var maxStars: Int = 3

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .foregroundStyle(index < stars ? Color.appAccent : Color.appTextSecondary)
            }
        }
    }
}

struct AppCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.98),
                    Color.appBackground.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.appAccent.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.32), radius: 14, x: 0, y: 10)
        .shadow(color: Color.appAccent.opacity(0.08), radius: 20, x: 0, y: 0)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

extension TimeInterval {
    var mmss: String {
        let total = Int(self.rounded())
        let mins = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
