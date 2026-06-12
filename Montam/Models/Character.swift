//
//  Character.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct Character: Codable, Identifiable, Hashable {

    let id: String
    let name: String
    let rarity: CharacterRarity
    let role: String
    let skills: [Skill]
    let stats: Stats
    let energyType: String

    let sprite: String
    let skins: [Skin]

    // computed -> ok
    var defaultSkin: Skin? {
        skins.first(where: { $0.id == "default" }) ?? skins.first
    }

    struct Stats: Codable, Hashable {
        let hp: Int
        let attack: Int
        let energyPower: Int
        let attackSpeed: Double
    }

    struct Skin: Codable, Identifiable, Hashable {
        let id: String
        let sprite: String
    }
}
