//
//  BattleRuntimeData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum BattleSide {
    case player
    case support
    case enemy
}

struct BattleStats {
    let level: Int
    let maxHP: Int
    let attack: Int
    let defense: Int
}

struct BattleSupportStats {
    let attackBonus: Double
    let defenseBonus: Double
    let healthBonus: Double
}

struct RuntimeOwnedMonster {
    let monsterId: String
    let level: Int
    let xp: Int
    let imageName: String?
}

struct RuntimeOwnedTamer {
    let tamerId: String
    let level: Int
    let xp: Int
}
