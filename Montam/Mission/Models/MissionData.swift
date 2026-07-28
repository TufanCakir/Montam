//
//  MissionData.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import Foundation

struct MissionData: Decodable, Identifiable {
    let id: String
    let title: String
    let description: String
    let titleKey: String?
    let descriptionKey: String?
    let kind: MissionKind
    let target: Int
    let repeatStep: Int?
    let maxClaims: Int?
    let rewards: [RewardData]

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedDescription: String {
        if let descriptionKey {
            return AppLocalizationService.text(descriptionKey)
        }

        return description
    }
}

enum MissionKind: String, Decodable {
    case reachStage
    case reachPlayerLevel
    case reachPower
    case collectCoins
    case collectCrystals
}

struct MissionProgress: Identifiable {
    let mission: MissionData
    let claimIndex: Int
    let currentValue: Int
    let targetValue: Int
    let isClaimed: Bool

    var id: String {
        "\(mission.id)_\(claimIndex)"
    }

    var progress: Double {
        min(Double(currentValue) / Double(max(targetValue, 1)), 1)
    }

    var canClaim: Bool {
        currentValue >= targetValue && !isClaimed
    }
}
