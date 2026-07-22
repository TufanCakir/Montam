//
//  GameProgressionData.swift
//  Monster Transorfmieren
//

import Foundation

struct GameProgressionData: Decodable {
    let maxLevel: Int?
    let xpBase: Int?
    let xpLinearGrowth: Int?
    let xpExponentialGrowth: Double?

    init(
        maxLevel: Int? = nil,
        xpBase: Int? = nil,
        xpLinearGrowth: Int? = nil,
        xpExponentialGrowth: Double? = nil
    ) {
        self.maxLevel = maxLevel
        self.xpBase = xpBase
        self.xpLinearGrowth = xpLinearGrowth
        self.xpExponentialGrowth = xpExponentialGrowth
    }

    var resolvedMaxLevel: Int { max(maxLevel ?? 100, 1) }
    var resolvedXPBase: Int { max(xpBase ?? 100, 1) }
    var resolvedXPLinearGrowth: Int { max(xpLinearGrowth ?? 35, 0) }
    var resolvedXPExponentialGrowth: Double { max(xpExponentialGrowth ?? 1.04, 1) }
}

enum GameProgressionCalculator {
    static func xpNeeded(for level: Int, progression: GameProgressionData) -> Int {
        let safeLevel = max(level, 1)
        let linear = progression.resolvedXPBase + max(safeLevel - 1, 0) * progression.resolvedXPLinearGrowth
        let exponential = pow(progression.resolvedXPExponentialGrowth, Double(safeLevel - 1))
        return max(Int((Double(linear) * exponential).rounded()), 1)
    }

    static func power(for monster: MonsterData, level: Int) -> Int {
        let growth = monster.monsterGrowthRate ?? 1
        let multiplier = pow(growth, Double(max(level - 1, 0)))
        let hp = Int(Double(monster.hp ?? 0) * multiplier) / 10
        let attack = Int(Double(monster.attack ?? 0) * multiplier)
        let defense = Int(Double(monster.defense ?? 0) * multiplier)
        return hp + attack + defense
    }
}
