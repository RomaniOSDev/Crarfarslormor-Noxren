//
//  TraditionTrotView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI

struct TraditionTrotView: View {
    @StateObject private var viewModel: TraditionTrotViewModel
    @State private var currentNodeID = ""
    let onFinish: (ActivityCompletion) -> Void

    init(level: Int, difficulty: Difficulty, onFinish: @escaping (ActivityCompletion) -> Void) {
        _viewModel = StateObject(wrappedValue: TraditionTrotViewModel(level: level, difficulty: difficulty))
        self.onFinish = onFinish
    }

    var body: some View {
        storyScreen(nodeID: currentNodeID.isEmpty ? viewModel.startNodeID : currentNodeID)
            .onAppear {
                if currentNodeID.isEmpty {
                    currentNodeID = viewModel.startNodeID
                }
            }
        .onChange(of: viewModel.isFinished) { finished in
            if finished {
                onFinish(viewModel.completion())
            }
        }
    }

    @ViewBuilder
    private func storyScreen(nodeID: String) -> some View {
        let node = viewModel.node(for: nodeID)
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.chapterTitle)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appAccent)
                            Text(node.title)
                                .font(.title3.bold())
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        Spacer()
                        if viewModel.difficulty == .hard {
                            Text("Time: \(viewModel.timeRemaining)s")
                                .foregroundStyle(Color.appAccent)
                        }
                    }
                    Text(node.detail)
                        .foregroundStyle(Color.appTextSecondary)
                }

                if node.isEnding {
                    Button("Finish Route") {
                        onFinish(viewModel.completion())
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                } else {
                    AppCard {
                        Text("Choose your action")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        ForEach(node.choices, id: \.title) { choice in
                            Button {
                                viewModel.apply(choice)
                                currentNodeID = choice.destination
                            } label: {
                                HStack {
                                    Text(choice.title)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer()
                                    if viewModel.difficulty == .easy, choice.title == viewModel.suggestedChoiceTitle(currentNodeID: nodeID) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundStyle(Color.appAccent)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 44)
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
    }
}
