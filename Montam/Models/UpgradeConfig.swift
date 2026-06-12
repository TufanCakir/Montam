//
//  UpgradeConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct UpgradeConfigRoot: Codable {
    let medalDefinitions: [MontamMedalDefinition]
    let starCosts: [StarUpgradeCost]
}

struct MontamMedalDefinition: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let characterId: String
}

struct StarUpgradeCost: Codable, Identifiable, Hashable {
    let fromStar: Int
    let toStar: Int
    let medals: Int
    let montamCoins: Int?

    var id: Int { fromStar }
}

enum UpgradeConfigLoader {
    static func load() -> UpgradeConfigRoot {
        do {
            return try JSONLoader.load("upgrade_config")
        } catch {
            print("upgrade_config.json konnte nicht geladen werden:", error)
            return UpgradeConfigRoot(
                medalDefinitions: [],
                starCosts: [
                    StarUpgradeCost(
                        fromStar: 1,
                        toStar: 2,
                        medals: 20,
                        montamCoins: 100
                    ),
                    StarUpgradeCost(
                        fromStar: 2,
                        toStar: 3,
                        medals: 45,
                        montamCoins: 250
                    ),
                    StarUpgradeCost(
                        fromStar: 3,
                        toStar: 4,
                        medals: 90,
                        montamCoins: 600
                    ),
                    StarUpgradeCost(
                        fromStar: 4,
                        toStar: 5,
                        medals: 160,
                        montamCoins: 1200
                    ),
                    StarUpgradeCost(
                        fromStar: 5,
                        toStar: 6,
                        medals: 260,
                        montamCoins: 2200
                    ),
                    StarUpgradeCost(
                        fromStar: 6,
                        toStar: 7,
                        medals: 420,
                        montamCoins: 4000
                    ),
                ]
            )
        }
    }
}
