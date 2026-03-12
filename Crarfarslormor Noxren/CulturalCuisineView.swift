//
//  CulturalCuisineView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct CulturalCuisineView: View {
    @StateObject private var viewModel: CulturalCuisineViewModel
    let onFinish: (ActivityCompletion) -> Void

    init(level: Int, difficulty: Difficulty, onFinish: @escaping (ActivityCompletion) -> Void) {
        _viewModel = StateObject(wrappedValue: CulturalCuisineViewModel(level: level, difficulty: difficulty))
        self.onFinish = onFinish
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppCard {
                    Text(viewModel.recipe.dish)
                        .font(.title3.bold())
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Region: \(viewModel.recipe.country)")
                        .foregroundStyle(Color.appTextSecondary)

                    if viewModel.difficulty == .easy {
                        Text("Hint: add \(viewModel.recipe.ingredients.joined(separator: ", "))")
                            .foregroundStyle(Color.appAccent)
                            .font(.subheadline)
                    }
                    if viewModel.difficulty == .hard {
                        Text("Time: \(viewModel.timeRemaining)s")
                            .foregroundStyle(Color.appAccent)
                            .font(.subheadline.weight(.semibold))
                    }
                }

                AppCard {
                    Text("Drag ingredients into the pot")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("You can also tap ingredients to add them.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)

                    PotDropZone(ingredients: viewModel.addedIngredients)
                        .onDrop(of: [UTType.text], isTargeted: nil) { providers in
                            if let provider = providers.first {
                                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { item, _ in
                                    if let data = item as? Data, let text = String(data: data, encoding: .utf8) {
                                        DispatchQueue.main.async {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                viewModel.addIngredient(text)
                                            }
                                        }
                                    } else if let text = item as? String {
                                        DispatchQueue.main.async {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                viewModel.addIngredient(text)
                                            }
                                        }
                                    }
                                }
                                return true
                            }
                            return false
                        }
                }

                AppCard {
                    Text("Ingredients")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                        ForEach(viewModel.availableIngredients, id: \.self) { item in
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    viewModel.addIngredient(item)
                                }
                            } label: {
                                Text(item)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.plain)
                            .background(Color.appBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onDrag { NSItemProvider(object: item as NSString) }
                        }
                    }
                }

                Button("Cook Dish") {
                    viewModel.finishCooking()
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .appScreenBackground()
        .onChange(of: viewModel.isFinished) { isFinished in
            if isFinished {
                onFinish(viewModel.completion())
            }
        }
    }
}

private struct PotDropZone: View {
    let ingredients: [String]

    var body: some View {
        ZStack {
            CookingPotShape()
                .fill(Color.appPrimary.opacity(0.8))
                .frame(height: 190)
            VStack(spacing: 6) {
                Text("Cooking Pot")
                    .foregroundStyle(Color.appTextPrimary)
                    .font(.headline)
                if ingredients.isEmpty {
                    Text("Drop ingredients here")
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    Text(ingredients.joined(separator: ", "))
                        .foregroundStyle(Color.appTextPrimary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

private struct CookingPotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bowlRect = CGRect(x: rect.minX + 16, y: rect.midY - 20, width: rect.width - 32, height: rect.height * 0.5)
        path.addRoundedRect(in: bowlRect, cornerSize: CGSize(width: 24, height: 24))
        path.move(to: CGPoint(x: rect.midX - 40, y: rect.midY - 32))
        path.addLine(to: CGPoint(x: rect.midX + 40, y: rect.midY - 32))
        path.addLine(to: CGPoint(x: rect.midX + 32, y: rect.midY - 20))
        path.addLine(to: CGPoint(x: rect.midX - 32, y: rect.midY - 20))
        path.closeSubpath()
        return path
    }
}
