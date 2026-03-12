//
//  Models.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 12.03.2026.
//

import Foundation

enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"

    var id: String { rawValue }

    var timerMultiplier: Double {
        switch self {
        case .easy: return 1.3
        case .normal: return 1.0
        case .hard: return 0.75
        }
    }

    var cueStrength: Double {
        switch self {
        case .easy: return 1.0
        case .normal: return 0.45
        case .hard: return 0.0
        }
    }
}

enum ActivityType: String, CaseIterable, Codable, Identifiable {
    case landmarkQuest
    case culturalCuisine
    case traditionTrot

    static let maxLevel = 12

    var id: String { rawValue }

    var title: String {
        switch self {
        case .landmarkQuest: return "Landmark Quest"
        case .culturalCuisine: return "Cultural Cuisine"
        case .traditionTrot: return "Tradition Trot"
        }
    }

    var subtitle: String {
        switch self {
        case .landmarkQuest: return "Reveal iconic landmarks with quick matching."
        case .culturalCuisine: return "Assemble global dishes in an interactive pot."
        case .traditionTrot: return "Navigate festival choices and cultural moments."
        }
    }

    var iconSystemName: String {
        switch self {
        case .landmarkQuest: return "building.columns.fill"
        case .culturalCuisine: return "fork.knife.circle.fill"
        case .traditionTrot: return "figure.walk.diamond.fill"
        }
    }
}

struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
}

struct ActivitySessionConfig: Hashable {
    let activity: ActivityType
    let difficulty: Difficulty
    let level: Int
}

struct ActivityCompletion {
    let stars: Int
    let duration: TimeInterval
    let summary: String
}
