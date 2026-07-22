//
//  BattleStatCalculator.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum BattleStatCalculator {
    static func monsterStats(
        from config: BattleUnitConfig,
        monster: MonsterData,
        battleConfig: BattleConfigData
    ) -> BattleStats {
        let level = min(config.level ?? 1, battleConfig.maxLevel ?? 100)
        let growth = monster.monsterGrowthRate ?? 1.0
        return BattleStats(
            level: level,
            maxHP: scaledStat(
                base: monster.hp ?? 1_000,
                level: level,
                growth: growth,
                multiplier: config.hpMultiplier ?? 1
            ),
            attack: scaledStat(
                base: monster.attack ?? 100,
                level: level,
                growth: growth
            ),
            defense: scaledStat(
                base: monster.defense ?? 20,
                level: level,
                growth: growth
            )
        )
    }

    static func enemyStats(from config: BattleUnitConfig, enemy: EnemyData)
        -> BattleStats
    {
        let level = config.level ?? enemy.level ?? 1
        let growth = enemy.enemyGrowthRate ?? 1.0
        return BattleStats(
            level: level,
            maxHP: scaledStat(
                base: enemy.hp ?? 1_000,
                level: level,
                growth: growth,
                multiplier: config.hpMultiplier ?? 1
            ),
            attack: scaledStat(
                base: enemy.attack ?? 100,
                level: level,
                growth: growth
            ),
            defense: scaledStat(
                base: enemy.defense ?? 20,
                level: level,
                growth: growth
            )
        )
    }

    static func tamerStats(from config: BattleUnitConfig, tamer: TamerData)
        -> BattleSupportStats
    {
        let level = max(config.level ?? 1, 1)
        let growth = pow(tamer.tamerGrowthRate ?? 1, Double(level - 1))
        return BattleSupportStats(
            attackBonus: (tamer.supportAttackBonus ?? 0) * growth,
            defenseBonus: (tamer.supportDefenseBonus ?? 0) * growth,
            healthBonus: (tamer.supportHealthBonus ?? 0) * growth
        )
    }

    private static func scaledStat(
        base: Int,
        level: Int,
        growth: Double,
        multiplier: Double = 1
    ) -> Int {
        let safeLevel = max(level, 1)
        let scaled =
            Double(base) * pow(growth, Double(safeLevel - 1)) * multiplier
        return max(Int(scaled.rounded()), 1)
    }
}
