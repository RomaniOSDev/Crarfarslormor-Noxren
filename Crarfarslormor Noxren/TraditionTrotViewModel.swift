//
//  TraditionTrotViewModel.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import Foundation
import Combine

final class TraditionTrotViewModel: ObservableObject {
    struct Choice: Hashable {
        let title: String
        let destination: String
        let isGoodChoice: Bool
    }

    struct Node {
        let id: String
        let title: String
        let detail: String
        let choices: [Choice]
        let isEnding: Bool
    }

    @Published private(set) var goodChoices = 0
    @Published var timeRemaining: Int = 0
    @Published var isFinished = false

    let level: Int
    let difficulty: Difficulty
    let startNodeID: String
    let chapterTitle: String

    private let startDate = Date()
    private var timer: AnyCancellable?
    private let routeNodes: [String: Node]
    private let targetGoodChoices: Int

    init(level: Int, difficulty: Difficulty) {
        self.level = level
        self.difficulty = difficulty
        let route = Self.makeRoute(level: level)
        self.routeNodes = route.nodes
        self.startNodeID = route.startID
        self.chapterTitle = route.chapterTitle
        self.targetGoodChoices = min(4, 2 + (level - 1) / 4)
        if difficulty == .hard {
            timeRemaining = max(12, 40 - (level * 2))
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }
                    guard self.timeRemaining > 0, !self.isFinished else { return }
                    self.timeRemaining -= 1
                    if self.timeRemaining <= 0 {
                        self.isFinished = true
                    }
                }
        }
    }

    deinit {
        timer?.cancel()
    }

    func node(for id: String) -> Node {
        if let node = routeNodes[id] {
            return node
        }
        if let startNode = routeNodes[startNodeID] {
            return startNode
        }
        return Node(
            id: "fallback",
            title: "Route Unavailable",
            detail: "Please return and start this level again.",
            choices: [],
            isEnding: true
        )
    }

    func apply(_ choice: Choice) {
        if choice.isGoodChoice { goodChoices += 1 }
        if node(for: choice.destination).isEnding {
            timer?.cancel()
        }
    }

    func suggestedChoiceTitle(currentNodeID: String) -> String? {
        guard difficulty == .easy else { return nil }
        return node(for: currentNodeID).choices.first(where: { $0.isGoodChoice })?.title
    }

    func completion() -> ActivityCompletion {
        let elapsed = Date().timeIntervalSince(startDate)
        let stars = score(elapsed: elapsed)
        let summary = "You made \(goodChoices) culturally aligned decisions."
        return ActivityCompletion(stars: stars, duration: elapsed, summary: summary)
    }

    private func score(elapsed: TimeInterval) -> Int {
        var stars = 1
        if goodChoices >= targetGoodChoices { stars += 1 }
        let speedTarget = max(14, 34 - level)
        if difficulty != .hard || elapsed < Double(speedTarget) { stars += 1 }
        return min(3, max(1, stars))
    }

    private static func makeRoute(level: Int) -> (chapterTitle: String, startID: String, nodes: [String: Node]) {
        let safeLevel = min(max(level, 1), 12)
        let chapter = (safeLevel - 1) / 4
        let episode = (safeLevel - 1) % 4
        let prefix = "c\(chapter)e\(episode)"

        let chapterTitles = ["Chapter 1: City Festivals", "Chapter 2: Mountain Ceremonies", "Chapter 3: Coastal Traditions"]
        let startTitles = [
            ["Lantern Opening", "Market Drums", "Craft Parade", "Old Town Night"],
            ["High Pass Gathering", "Stone Circle Rite", "Peak Fire March", "Valley Echo Event"],
            ["Harbor Sunrise", "Sea Blessing Walk", "Tide Lantern Route", "Cliff Song Ceremony"]
        ]
        let startDetails = [
            [
                "The city square is preparing for an evening lantern release.",
                "Street musicians begin the opening rhythm for local guests.",
                "Artisans organize symbolic masks before the parade starts.",
                "Old town hosts a twilight route through historic alleys."
            ],
            [
                "Mountain hosts welcome visitors at a high-altitude gateway.",
                "A stone circle ceremony begins at dawn with guided steps.",
                "Participants gather for a torch march through narrow paths.",
                "The valley echoes with chants before the final procession."
            ],
            [
                "Local crews prepare a sunrise welcome by the harbor.",
                "Visitors are invited to a coastal blessing route.",
                "Families line up for a tide lantern walk along the bay.",
                "A cliffside stage opens with traditional chorus lines."
            ]
        ]

        let startID = "\(prefix)_start"
        let prepID = "\(prefix)_prep"
        let crowdID = "\(prefix)_crowd"
        let paradeID = "\(prefix)_parade"
        let detourID = "\(prefix)_detour"
        let ritualID = "\(prefix)_ritual"
        let goodEndID = "\(prefix)_good_end"
        let neutralEndID = "\(prefix)_neutral_end"
        let shortEndID = "\(prefix)_short_end"

        let hasExtendedBranch = safeLevel >= 9

        var nodes: [String: Node] = [:]
        nodes[startID] = Node(
            id: startID,
            title: startTitles[chapter][episode],
            detail: startDetails[chapter][episode],
            choices: [
                .init(title: "Follow host guidance", destination: prepID, isGoodChoice: true),
                .init(title: "Rush without context", destination: crowdID, isGoodChoice: false)
            ],
            isEnding: false
        )
        nodes[prepID] = Node(
            id: prepID,
            title: "Community Preparation",
            detail: "A local coordinator explains etiquette and symbolic actions for this route.",
            choices: [
                .init(title: "Ask for meaning before acting", destination: paradeID, isGoodChoice: true),
                .init(title: "Skip guidance and improvise", destination: detourID, isGoodChoice: false)
            ],
            isEnding: false
        )
        nodes[crowdID] = Node(
            id: crowdID,
            title: "Crowded Segment",
            detail: "The route gets dense and signs are harder to follow.",
            choices: [
                .init(title: "Pause and follow local markers", destination: paradeID, isGoodChoice: true),
                .init(title: "Push into the nearest lane", destination: detourID, isGoodChoice: false)
            ],
            isEnding: false
        )
        nodes[paradeID] = Node(
            id: paradeID,
            title: "Main Ceremony",
            detail: hasExtendedBranch
                ? "The main ceremony opens, followed by a deeper ritual segment."
                : "The main ceremony starts and asks participants to match local etiquette.",
            choices: [
                .init(
                    title: hasExtendedBranch ? "Respect sequence and continue" : "Match rhythm and etiquette",
                    destination: hasExtendedBranch ? ritualID : goodEndID,
                    isGoodChoice: true
                ),
                .init(
                    title: hasExtendedBranch ? "Ignore sequence and improvise" : "Ignore key instructions",
                    destination: neutralEndID,
                    isGoodChoice: false
                )
            ],
            isEnding: false
        )
        nodes[detourID] = Node(
            id: detourID,
            title: "Route Detour",
            detail: "You miss part of the event and need to choose how to re-enter.",
            choices: [
                .init(title: "Return via host checkpoint", destination: neutralEndID, isGoodChoice: true),
                .init(title: "Leave before final segment", destination: shortEndID, isGoodChoice: false)
            ],
            isEnding: false
        )

        if hasExtendedBranch {
            nodes[ritualID] = Node(
                id: ritualID,
                title: "Closing Ritual",
                detail: "A final tradition requires accurate timing and respectful sequence.",
                choices: [
                    .init(title: "Observe first, then participate", destination: goodEndID, isGoodChoice: true),
                    .init(title: "Act immediately without watching", destination: neutralEndID, isGoodChoice: false)
                ],
                isEnding: false
            )
        }

        nodes[goodEndID] = Node(
            id: goodEndID,
            title: "Cultural Success",
            detail: "You complete this route with strong awareness and respectful decisions.",
            choices: [],
            isEnding: true
        )
        nodes[neutralEndID] = Node(
            id: neutralEndID,
            title: "Balanced Finish",
            detail: "You complete the route with partial alignment to local practice.",
            choices: [],
            isEnding: true
        )
        nodes[shortEndID] = Node(
            id: shortEndID,
            title: "Early Exit",
            detail: "You exit before the final moment and gain limited insight.",
            choices: [],
            isEnding: true
        )

        return (chapterTitles[chapter], startID, nodes)
    }
}
