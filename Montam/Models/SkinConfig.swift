//
//  SkinConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct SkinConfigRoot: Codable {
    let skins: [MontamSkinDefinition]
}

struct MontamSkinDefinition: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let characterId: String
    let image: String
    let rarity: CharacterRarity
    let source: String?
    let isEventLimited: Bool?
    let startDate: String?
    let endDate: String?
    let description: String?
}

enum SkinConfigLoader {
    static func load() -> SkinConfigRoot {
        do {
            return try JSONLoader.load("skins")
        } catch {
            print("skins.json konnte nicht geladen werden:", error)
            return SkinConfigRoot(skins: [])
        }
    }
}
