//
//  BattleConfigData.swift
//  Monster Transorfmieren
//

import Foundation

struct BattleConfigData: Decodable {
    let groundYRatio: Double
    let edgeXPadding: Double
    let maxPlayerMonsters: Int
    let maxSupportTamers: Int
    let walkDuration: Double
    let attackInterval: Double
    let fadeDuration: Double
    let worldWidthMultiplier: Double?
    let worldScrollStepRatio: Double?
    let playerSpriteMaxHeightRatio: Double?
    let supportSpriteMaxHeightRatio: Double?
    let enemySpriteMaxHeightRatio: Double?
    let backgroundTransitionFightCount: Int?
    let maxLevel: Int?
    let backgroundSequence: [String]
    let playerMonsters: [BattleUnitConfig]
    let supportTamers: [BattleUnitConfig]
    let waves: [BattleWaveData]
    let rewards: BattleRewardConfig
}

struct BattleWaveData: Decodable {
    let backgroundIndex: Int
    let isBossWave: Bool
    let xpReward: Int?
    let enemies: [BattleUnitConfig]
}

struct BattleUnitConfig: Decodable {
    let id: String
    let level: Int?
    let slot: Int
    let hpMultiplier: Double?
    let scaleMultiplier: Double?
}

struct BattleRewardConfig: Decodable {
    let coinIcon: String
    let crystalIcon: String
    let coins: Int
    let crystals: Int
    let eventExp: Int
}

extension BattleConfigData {
    func configuredForEvent(_ event: EventData) -> BattleConfigData {
        let eventRewards = JSONDataLoader.load("eventReward", as: [EventRewardData].self)?.first
        let reward = BattleRewardConfig(
            coinIcon: rewards.coinIcon,
            crystalIcon: rewards.crystalIcon,
            coins: eventRewards?.eventCoins ?? rewards.coins,
            crystals: eventRewards?.eventCrystals ?? rewards.crystals,
            eventExp: eventRewards?.eventExp ?? rewards.eventExp
        )

        let normalWave = BattleWaveData(
            backgroundIndex: 0,
            isBossWave: false,
            xpReward: max((eventRewards?.eventExp ?? rewards.eventExp) / 3, 1),
            enemies: [
                BattleUnitConfig(id: event.enemyName, level: 1, slot: 0, hpMultiplier: nil, scaleMultiplier: nil),
                BattleUnitConfig(id: event.enemyName, level: 1, slot: 1, hpMultiplier: nil, scaleMultiplier: nil)
            ]
        )
        let bossWave = BattleWaveData(
            backgroundIndex: 0,
            isBossWave: true,
            xpReward: eventRewards?.eventExp ?? rewards.eventExp,
            enemies: [
                BattleUnitConfig(id: event.enemyName, level: 3, slot: 0, hpMultiplier: 1.7, scaleMultiplier: 1.35)
            ]
        )

        return BattleConfigData(
            groundYRatio: groundYRatio,
            edgeXPadding: edgeXPadding,
            maxPlayerMonsters: maxPlayerMonsters,
            maxSupportTamers: maxSupportTamers,
            walkDuration: walkDuration,
            attackInterval: attackInterval,
            fadeDuration: fadeDuration,
            worldWidthMultiplier: worldWidthMultiplier,
            worldScrollStepRatio: worldScrollStepRatio,
            playerSpriteMaxHeightRatio: playerSpriteMaxHeightRatio,
            supportSpriteMaxHeightRatio: supportSpriteMaxHeightRatio,
            enemySpriteMaxHeightRatio: enemySpriteMaxHeightRatio,
            backgroundTransitionFightCount: backgroundTransitionFightCount,
            maxLevel: maxLevel,
            backgroundSequence: [event.eventBackground],
            playerMonsters: playerMonsters,
            supportTamers: supportTamers,
            waves: [normalWave, bossWave],
            rewards: reward
        )
    }
}
