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
    let maxXP: Int?
    let imageName: String?

    init(
        monsterId: String,
        level: Int,
        xp: Int,
        maxXP: Int? = nil,
        imageName: String?
    ) {
        self.monsterId = monsterId
        self.level = level
        self.xp = xp
        self.maxXP = maxXP
        self.imageName = imageName
    }
}

struct RuntimeOwnedTamer {
    let tamerId: String
    let level: Int
    let xp: Int
}

struct BattleWaveReward {
    let xp: Int
    let coins: Int
    let crystals: Int
    let bits: Int
    let summonTickets: Int
}
