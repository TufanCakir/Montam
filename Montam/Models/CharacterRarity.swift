//
//  CharacterRarity.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

enum CharacterRarity: String, Codable {

    case common
    case rare
    case epic
    case legendary
}

extension CharacterRarity {

    var evolutionStageTitle: String {
        switch self {
        case .common: return "Feral"
        case .rare: return "Tamed"
        case .epic: return "Mastered"
        case .legendary: return "Exalted"
        }
    }

    // 🎨 UI
    var color: Color {
        switch self {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        }
    }

    // 📈 Scaling (late game balance verbessert)
    var growthRate: Double {
        switch self {
        case .common: return 1.05  // sehr schwach scaling
        case .rare: return 1.065
        case .epic: return 1.085
        case .legendary: return 1.11  // leicht stärker gemacht
        }
    }

    // 🎯 GLOBAL DROP RATE
    var summonRate: Double {
        switch self {
        case .common: return 0.65  // 65%
        case .rare: return 0.25  // 25%
        case .epic: return 0.08  // 8%
        case .legendary: return 0.015  // 1.5%
        }
    }
}
