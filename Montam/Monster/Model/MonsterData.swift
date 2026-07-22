//
//  MonsterData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct MonsterData: Codable {
    let id: String
    let monsterName: String
    let name: String
    let rarity: String?
    let hp: Int?
    let attack: Int?
    let defense: Int?
    let level: Int?
    let xp: Int?
    let monsterGrowthRate: Double?
    let yOffset: Int
    let xOffset: Int
    let zOffset: Int
}
