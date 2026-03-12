//
//  LandmarkQuestViewModel.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import Foundation
import Combine

final class LandmarkQuestViewModel: ObservableObject {
    struct LandmarkItem {
        let name: String
        let triviaQuestion: String
        let triviaAnswers: [String]
        let correctAnswer: String
    }

    @Published private(set) var current: LandmarkItem
    @Published private(set) var options: [String]
    @Published var revealProgress: Double = 0.25
    @Published var timeRemaining: Int = 0
    @Published var matched = false
    @Published var triviaVisible = false
    @Published var triviaSolved = false
    @Published var isFinished = false
    @Published var summary = ""

    let level: Int
    let difficulty: Difficulty

    private let startDate = Date()
    private var timer: AnyCancellable?
    private var usedWrongAttempts = 0
    private var didTimeout = false
    private let revealStep: Double

    private let bank: [LandmarkItem] = [
        .init(
            name: "Sky Arch",
            triviaQuestion: "Which region is known for this arch style?",
            triviaAnswers: ["Coastal South", "Northern Highlands", "Central Plains"],
            correctAnswer: "Northern Highlands"
        ),
        .init(
            name: "Sun Tower",
            triviaQuestion: "What was the original purpose of this tower?",
            triviaAnswers: ["Navigation", "Royal storage", "Astronomy"],
            correctAnswer: "Navigation"
        ),
        .init(
            name: "River Citadel",
            triviaQuestion: "Which natural element surrounds this citadel?",
            triviaAnswers: ["Desert dunes", "River bends", "Volcanic rock"],
            correctAnswer: "River bends"
        ),
        .init(
            name: "Moon Gate",
            triviaQuestion: "What is the gate mainly associated with?",
            triviaAnswers: ["Seasonal festivals", "Military defense", "Trade taxation"],
            correctAnswer: "Seasonal festivals"
        ),
        .init(
            name: "Amber Fortress",
            triviaQuestion: "Which terrain best protects this fortress?",
            triviaAnswers: ["Cliff edge", "Open meadow", "Salt flat"],
            correctAnswer: "Cliff edge"
        ),
        .init(
            name: "Crystal Bridge",
            triviaQuestion: "What made this crossing famous historically?",
            triviaAnswers: ["Ceremonial routes", "Stone carving schools", "Irrigation systems"],
            correctAnswer: "Ceremonial routes"
        ),
        .init(
            name: "Ivory Pillar",
            triviaQuestion: "Which craft is linked to this monument?",
            triviaAnswers: ["Metal bells", "Mosaic tiling", "Silk weaving"],
            correctAnswer: "Mosaic tiling"
        ),
        .init(
            name: "Wind Terrace",
            triviaQuestion: "Why was this place built on elevation?",
            triviaAnswers: ["Stronger winds for cooling", "Shorter trade paths", "River fishing access"],
            correctAnswer: "Stronger winds for cooling"
        ),
        .init(
            name: "Echo Shrine",
            triviaQuestion: "What is the shrine best known for?",
            triviaAnswers: ["Acoustic chants", "Market ceremonies", "Night farming rituals"],
            correctAnswer: "Acoustic chants"
        ),
        .init(
            name: "Dawn Observatory",
            triviaQuestion: "Which activity happened here at sunrise?",
            triviaAnswers: ["Star tracking", "Horse trading", "Salt drying"],
            correctAnswer: "Star tracking"
        ),
        .init(
            name: "Cedar Citadel",
            triviaQuestion: "Which material dominates the original structures?",
            triviaAnswers: ["Cedar timber", "Polished marble", "Clay brick"],
            correctAnswer: "Cedar timber"
        ),
        .init(
            name: "Harbor Spire",
            triviaQuestion: "Who mainly used this spire in old routes?",
            triviaAnswers: ["Sea navigators", "Mountain herders", "Forest surveyors"],
            correctAnswer: "Sea navigators"
        ),
        .init(
            name: "Aurora Plaza",
            triviaQuestion: "Which event is tied to this plaza?",
            triviaAnswers: ["Winter lantern parades", "Harvest auctions", "River launch races"],
            correctAnswer: "Winter lantern parades"
        )
    ]

    init(level: Int, difficulty: Difficulty) {
        self.level = level
        self.difficulty = difficulty
        let selected = bank[(max(level, 1) - 1) % bank.count]
        self.current = selected
        self.options = Self.makeOptions(
            correct: selected.name,
            in: bank.map(\.name),
            level: level,
            difficulty: difficulty
        )
        self.revealProgress = Self.startReveal(level: level, difficulty: difficulty)
        self.revealStep = Self.revealStep(level: level, difficulty: difficulty)
        configureTimerIfNeeded()
    }

    deinit {
        timer?.cancel()
    }

    func handleDrop(name: String) {
        guard !isFinished else { return }
        if name == current.name {
            matched = true
            revealProgress = 1
            if difficulty == .hard {
                triviaVisible = true
            } else {
                finish()
            }
        } else {
            usedWrongAttempts += 1
            revealProgress = min(1, revealProgress + revealStep)
        }
    }

    func answerTrivia(_ answer: String) {
        guard triviaVisible, !isFinished else { return }
        triviaSolved = answer == current.correctAnswer
        finish()
    }

    private func configureTimerIfNeeded() {
        guard difficulty != .easy else { return }
        let base = max(7, 24 - level)
        timeRemaining = Int(Double(base) * difficulty.timerMultiplier)
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.timeRemaining > 0, !self.isFinished else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.didTimeout = true
                    self.finish()
                }
            }
    }

    private func finish() {
        guard !isFinished else { return }
        timer?.cancel()
        isFinished = true
        summary = matched
            ? "Landmark identified successfully."
            : "The route ended before a full reveal."
    }

    func completion() -> ActivityCompletion {
        let elapsed = Date().timeIntervalSince(startDate)
        let stars = score(elapsed: elapsed)
        return ActivityCompletion(stars: stars, duration: elapsed, summary: summary)
    }

    private func score(elapsed: TimeInterval) -> Int {
        if didTimeout && !matched {
            return 1
        }
        var score = 1
        if matched { score += 1 }
        if difficulty == .hard {
            if triviaSolved && usedWrongAttempts <= max(0, 3 - level / 4) { score += 1 }
        } else if difficulty == .normal {
            let ratio = timeRemaining > 0 ? Double(timeRemaining) / Double(max(timeRemaining + Int(elapsed), 1)) : 0
            if ratio > (0.30 - Double(min(level, 10)) * 0.01) { score += 1 }
        } else {
            if usedWrongAttempts <= max(0, 2 - level / 5) { score += 1 }
        }
        return min(3, max(1, score))
    }

    private static func makeOptions(correct: String, in all: [String], level: Int, difficulty: Difficulty) -> [String] {
        let baseDecoys: Int
        switch difficulty {
        case .easy:
            baseDecoys = 3 + min(level / 5, 1)
        case .normal:
            baseDecoys = 4 + min(level / 4, 2)
        case .hard:
            baseDecoys = 5 + min(level / 3, 3)
        }
        let pool = all.filter { $0 != correct }.shuffled()
        return ([correct] + pool.prefix(baseDecoys)).shuffled()
    }

    private static func startReveal(level: Int, difficulty: Difficulty) -> Double {
        let levelPenalty = Double(min(level - 1, 10)) * 0.015
        switch difficulty {
        case .easy:
            return max(0.25, 0.48 - levelPenalty)
        case .normal:
            return max(0.18, 0.34 - levelPenalty)
        case .hard:
            return max(0.12, 0.24 - levelPenalty)
        }
    }

    private static func revealStep(level: Int, difficulty: Difficulty) -> Double {
        let base: Double
        switch difficulty {
        case .easy: base = 0.16
        case .normal: base = 0.13
        case .hard: base = 0.10
        }
        return max(0.06, base - Double(min(level, 10)) * 0.004)
    }
}
