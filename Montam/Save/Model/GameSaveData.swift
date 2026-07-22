//
//  GameSaveData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import Foundation
import SwiftData

@Model
final class GameSaveData {
    var createdAt: Date
    var didCompleteOnboarding: Bool
    var playerLevel: Int
    var playerPower: Int
    var playerXP: Int
    var playerMaxXP: Int
    var bits: Int
    var coins: Int
    var crystals: Int
    var summonTickets: Int
    var hasEventPass: Bool

    init(
        createdAt: Date = .now,
        didCompleteOnboarding: Bool = false,
        playerLevel: Int = 1,
        playerPower: Int = 0,
        playerXP: Int = 0,
        playerMaxXP: Int = 100,
        bits: Int = 0,
        coins: Int = 0,
        crystals: Int = 0,
        summonTickets: Int = 0,
        hasEventPass: Bool = false
    ) {
        self.createdAt = createdAt
        self.didCompleteOnboarding = didCompleteOnboarding
        self.playerLevel = playerLevel
        self.playerPower = playerPower
        self.playerXP = playerXP
        self.playerMaxXP = playerMaxXP
        self.bits = bits
        self.coins = coins
        self.crystals = crystals
        self.summonTickets = summonTickets
        self.hasEventPass = hasEventPass
    }
}

@Model
final class OwnedMonsterData {
    @Attribute(.unique) var monsterId: String
    var level: Int
    var xp: Int
    var isSelected: Bool

    init(monsterId: String, level: Int = 1, xp: Int = 0, isSelected: Bool = false) {
        self.monsterId = monsterId
        self.level = level
        self.xp = xp
        self.isSelected = isSelected
    }
}

@Model
final class OwnedTamerData {
    @Attribute(.unique) var tamerId: String
    var level: Int
    var xp: Int
    var isSelected: Bool

    init(tamerId: String, level: Int = 1, xp: Int = 0, isSelected: Bool = false) {
        self.tamerId = tamerId
        self.level = level
        self.xp = xp
        self.isSelected = isSelected
    }
}
