//
//  LandmarkQuestView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct LandmarkQuestView: View {
    @StateObject private var viewModel: LandmarkQuestViewModel
    let onFinish: (ActivityCompletion) -> Void

    init(level: Int, difficulty: Difficulty, onFinish: @escaping (ActivityCompletion) -> Void) {
        _viewModel = StateObject(wrappedValue: LandmarkQuestViewModel(level: level, difficulty: difficulty))
        self.onFinish = onFinish
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    HStack {
                        Text("Match the silhouette")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Spacer()
                        if viewModel.difficulty != .easy {
                            Text("Time: \(viewModel.timeRemaining)s")
                                .foregroundStyle(Color.appAccent)
                        }
                    }

                    ZStack {
                        LandmarkSilhouetteShape()
                            .fill(Color.appTextSecondary.opacity(0.25))
                            .frame(height: 190)
                        LandmarkSilhouetteShape()
                            .trim(from: 0, to: viewModel.revealProgress)
                            .stroke(Color.appAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(height: 190)
                            .animation(.easeInOut(duration: 0.35), value: viewModel.revealProgress)
                    }

                    selectionStatus
                }

                AppCard {
                    Text("Name tags")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(viewModel.options, id: \.self) { option in
                            Button {
                                viewModel.handleDrop(name: option)
                            } label: {
                                Text(option)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.plain)
                            .background(Color.appBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }

                if viewModel.triviaVisible {
                    AppCard {
                        Text(viewModel.current.triviaQuestion)
                            .foregroundStyle(Color.appTextPrimary)
                            .font(.headline)
                        ForEach(viewModel.current.triviaAnswers, id: \.self) { answer in
                            Button(answer) {
                                viewModel.answerTrivia(answer)
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .onChange(of: viewModel.isFinished) { newValue in
            if newValue {
                onFinish(viewModel.completion())
            }
        }
    }

    private var selectionStatus: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color.appBackground)
            .frame(height: 64)
            .overlay {
                Text(viewModel.matched ? "Matched" : "Tap the correct name below")
                    .foregroundStyle(viewModel.matched ? Color.appAccent : Color.appTextSecondary)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
    }
}

private struct LandmarkSilhouetteShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.3))
        path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.63, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.67, y: h * 0.95))
        path.addLine(to: CGPoint(x: w * 0.33, y: h * 0.95))
        path.addLine(to: CGPoint(x: w * 0.37, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.3))
        path.closeSubpath()
        return path
    }
}
