//
//  EggConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct EggConfigRoot: Codable {
    let eggs: [MontamEgg]
}

struct MontamEgg: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let eggImage: String
    let feralImage: String
    let characterId: String
    let hatchCostMontamLiquid: Int
    let rarity: CharacterRarity
    let element: String?
    let isLimited: Bool?
    let startDate: String?
    let endDate: String?
    let description: String?
}

enum EggConfigLoader {
    static func load() -> EggConfigRoot {
        do {
            return try JSONLoader.load("eggs")
        } catch {
            print("eggs.json konnte nicht geladen werden:", error)
            return EggConfigRoot(eggs: [])
        }
    }
}
