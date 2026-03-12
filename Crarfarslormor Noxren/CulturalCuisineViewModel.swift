//
//  CulturalCuisineViewModel.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import Foundation
import Combine

final class CulturalCuisineViewModel: ObservableObject {
    struct Recipe {
        let dish: String
        let country: String
        let ingredients: [String]
        let baseExtras: [String]
    }

    @Published private(set) var recipe: Recipe
    @Published private(set) var availableIngredients: [String]
    @Published private(set) var addedIngredients: [String] = []
    @Published var timeRemaining: Int = 0
    @Published var isFinished = false
    @Published var summary = ""

    let level: Int
    let difficulty: Difficulty

    private let startDate = Date()
    private var timer: AnyCancellable?
    private let maxFalseIngredients: Int

    private let recipes: [Recipe] = [
        .init(dish: "Spice Pot", country: "Highland Route", ingredients: ["Rice", "Pepper", "Herbs"], baseExtras: ["Apple", "Yogurt", "Mint"]),
        .init(dish: "Harbor Stew", country: "West Coast", ingredients: ["Beans", "Tomato", "Onion"], baseExtras: ["Cocoa", "Lime", "Flour"]),
        .init(dish: "Sunplate", country: "Valley Region", ingredients: ["Potato", "Olive", "Garlic"], baseExtras: ["Sugar", "Berry", "Milk"]),
        .init(dish: "River Bowl", country: "Eastern Plains", ingredients: ["Noodles", "Mushroom", "Ginger"], baseExtras: ["Vanilla", "Pear", "Butter"]),
        .init(dish: "Forest Broth", country: "Northern Ridge", ingredients: ["Leek", "Carrot", "Barley", "Salt"], baseExtras: ["Honey", "Bean", "Fig"]),
        .init(dish: "Golden Skillet", country: "Sunset Coast", ingredients: ["Corn", "Tomato", "Basil", "Onion"], baseExtras: ["Cinnamon", "Clover", "Peach"]),
        .init(dish: "Pearl Noodles", country: "Island Belt", ingredients: ["Noodles", "Sesame", "Seaweed", "Ginger"], baseExtras: ["Coffee", "Plum", "Cheese"]),
        .init(dish: "Market Roast", country: "Central Bazaar", ingredients: ["Potato", "Garlic", "Paprika", "Lentil"], baseExtras: ["Maple", "Mint", "Melon"]),
        .init(dish: "Winter Clay Pot", country: "Snow Frontier", ingredients: ["Turnip", "Onion", "Pepper", "Beans", "Thyme"], baseExtras: ["Cocoa", "Lemon", "Date"]),
        .init(dish: "River Feast", country: "Delta Route", ingredients: ["Rice", "Peas", "Chili", "Garlic", "Lime"], baseExtras: ["Walnut", "Cream", "Apple"]),
        .init(dish: "Summit Plate", country: "Peak Passage", ingredients: ["Quinoa", "Carrot", "Mushroom", "Onion", "Parsley"], baseExtras: ["Sugar", "Banana", "Coconut"]),
        .init(dish: "Twilight Stew", country: "Evening Archipelago", ingredients: ["Barley", "Bean", "Tomato", "Herbs", "Pepper"], baseExtras: ["Yam", "Chocolate", "Pear"])
    ]

    init(level: Int, difficulty: Difficulty) {
        self.level = level
        self.difficulty = difficulty
        let selected = recipes[(max(level, 1) - 1) % recipes.count]
        self.maxFalseIngredients = Self.falseIngredientTarget(level: level, difficulty: difficulty)
        self.recipe = selected
        self.availableIngredients = Self.makeIngredientPool(
            recipe: selected,
            falseIngredientCount: maxFalseIngredients
        )
        configureTimerIfNeeded()
    }

    deinit {
        timer?.cancel()
    }

    func addIngredient(_ ingredient: String) {
        guard !isFinished else { return }
        addedIngredients.append(ingredient)
    }

    func finishCooking() {
        guard !isFinished else { return }
        isFinished = true
        timer?.cancel()
        let required = Set(recipe.ingredients)
        let provided = Set(addedIngredients)
        let matched = required.intersection(provided).count
        summary = "You assembled \(matched)/\(required.count) key ingredients."
    }

    private func configureTimerIfNeeded() {
        guard difficulty != .easy else { return }
        let base = difficulty == .normal ? (36 - level) : (30 - level)
        timeRemaining = max(difficulty == .normal ? 14 : 9, Int(Double(base) * difficulty.timerMultiplier))
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.timeRemaining > 0, !self.isFinished else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.finishCooking()
                }
            }
    }

    func completion() -> ActivityCompletion {
        let elapsed = Date().timeIntervalSince(startDate)
        return ActivityCompletion(stars: score(elapsed: elapsed), duration: elapsed, summary: summary)
    }

    private func score(elapsed: TimeInterval) -> Int {
        let required = Set(recipe.ingredients)
        let provided = Set(addedIngredients)
        let matched = required.intersection(provided).count
        let wrongCount = provided.subtracting(required).count
        var stars = 1
        if matched == required.count { stars += 1 }
        let allowedWrong = max(0, maxFalseIngredients / 3)
        if wrongCount <= allowedWrong { stars += 1 }
        let timeThreshold = max(12, 30 - level)
        if difficulty == .hard && elapsed > Double(timeThreshold) { stars -= 1 }
        if difficulty == .normal && elapsed > Double(timeThreshold + 7) { stars -= 1 }
        return min(3, max(1, stars))
    }

    private static func makeIngredientPool(recipe: Recipe, falseIngredientCount: Int) -> [String] {
        let globalFalsePool = [
            "Honey", "Cocoa", "Plum", "Cheese", "Maple", "Date", "Cream", "Banana",
            "Coconut", "Chocolate", "Walnut", "Clover", "Melon", "Vanilla", "Apple", "Pear"
        ]
        var pool = recipe.ingredients
        let localFalse = recipe.baseExtras.shuffled()
        let globalFalse = globalFalsePool
            .filter { !recipe.ingredients.contains($0) && !recipe.baseExtras.contains($0) }
            .shuffled()
        let combinedFalse = localFalse + globalFalse
        let boundedCount = max(1, min(falseIngredientCount, combinedFalse.count))
        pool.append(contentsOf: combinedFalse.prefix(boundedCount))
        return pool.shuffled()
    }

    private static func falseIngredientTarget(level: Int, difficulty: Difficulty) -> Int {
        let stage = min(level - 1, 11)
        switch difficulty {
        case .easy:
            return 1 + stage / 4
        case .normal:
            return 2 + stage / 3
        case .hard:
            return 3 + stage / 2
        }
    }
}
