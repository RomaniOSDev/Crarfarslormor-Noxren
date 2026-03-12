//
//  OnboardingView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    var body: some View {
        VStack(spacing: 18) {
            TabView(selection: $page) {
                OnboardingCardView(
                    title: "Discover World Landmarks",
                    detail: "Reveal iconic silhouettes, learn quick facts, and progress through guided travel challenges.",
                    shape: .landmark
                )
                .tag(0)

                OnboardingCardView(
                    title: "Cook Across Cultures",
                    detail: "Build dishes from regional ingredients and improve your timing through multiple difficulty modes.",
                    shape: .cuisine
                )
                .tag(1)

                OnboardingCardView(
                    title: "Navigate Traditions",
                    detail: "Make festival decisions, unlock story routes, and earn stars as your global journey grows.",
                    shape: .tradition
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .interactive))

            HStack(spacing: 12) {
                if page > 0 {
                    Button("Back") { page -= 1 }
                        .buttonStyle(SecondaryActionButtonStyle())
                }

                Button(page == 2 ? "Start Exploring" : "Continue") {
                    if page == 2 {
                        onFinish()
                    } else {
                        page += 1
                    }
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .appScreenBackground()
    }
}

private struct OnboardingCardView: View {
    enum ShapeKind {
        case landmark
        case cuisine
        case tradition
    }

    let title: String
    let detail: String
    let shape: ShapeKind

    @State private var animate = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface.opacity(0.95), Color.appBackground.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(Color.appAccent.opacity(0.24), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.26), radius: 12, x: 0, y: 8)
                        .frame(height: 260)
                    animatedGraphic
                        .frame(width: 230, height: 210)
                }
                .padding(.top, 30)

                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text(detail)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var animatedGraphic: some View {
        switch shape {
        case .landmark:
            LandmarkOnboardingShape()
                .trim(from: 0, to: animate ? 1 : 0.01)
                .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .animation(.easeInOut(duration: 1.0), value: animate)
                .onAppear { animate = true }
        case .cuisine:
            CuisineOnboardingShape(fillLevel: animate ? 1 : 0.2)
                .fill(Color.appPrimary)
                .overlay {
                    CuisineOnboardingShape(fillLevel: animate ? 1 : 0.2)
                        .stroke(Color.appTextPrimary, lineWidth: 4)
                }
                .animation(.easeInOut(duration: 0.9), value: animate)
                .onAppear { animate = true }
        case .tradition:
            TraditionOnboardingShape(progress: animate ? 1 : 0.2)
                .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .animation(.easeInOut(duration: 1.2), value: animate)
                .onAppear { animate = true }
        }
    }
}

private struct LandmarkOnboardingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.35))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.62, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.67, y: h * 0.9))
        path.addLine(to: CGPoint(x: w * 0.33, y: h * 0.9))
        path.addLine(to: CGPoint(x: w * 0.38, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.35))
        path.closeSubpath()
        return path
    }
}

private struct CuisineOnboardingShape: Shape {
    var fillLevel: CGFloat

    var animatableData: CGFloat {
        get { fillLevel }
        set { fillLevel = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let level = max(0.2, min(fillLevel, 1))
        let bowl = CGRect(x: rect.width * 0.1, y: rect.height * 0.3, width: rect.width * 0.8, height: rect.height * 0.55)
        path.addRoundedRect(in: bowl, cornerSize: CGSize(width: 20, height: 20))
        let liquidHeight = bowl.height * level * 0.6
        path.addRect(CGRect(x: bowl.minX + 8, y: bowl.maxY - liquidHeight - 8, width: bowl.width - 16, height: liquidHeight))
        return path
    }
}

private struct TraditionOnboardingShape: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p = max(0.2, min(progress, 1))
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.8))
        path.addCurve(
            to: CGPoint(x: rect.width * (0.2 + 0.65 * p), y: rect.height * (0.25 + 0.35 * (1 - p))),
            control1: CGPoint(x: rect.width * 0.25, y: rect.height * 0.2),
            control2: CGPoint(x: rect.width * 0.7, y: rect.height * 0.95)
        )
        path.addEllipse(in: CGRect(x: rect.width * (0.75 * p), y: rect.height * (0.12 + 0.2 * (1 - p)), width: 34, height: 34))
        return path
    }
}
