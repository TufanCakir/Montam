//
//  BattleUnitFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit

enum BattleSpriteScale {
    static let playerMonster: CGFloat = 0.50
    static let tamer: CGFloat = 0.50
    static let supporter: CGFloat = 0.42
    static let enemy: CGFloat = 0.50
    static let boss: CGFloat = 0.80
}

struct BattleUnitFactory {
    let monsters: [MonsterData]
    let tamers: [TamerData]
    let enemies: [EnemyData]
    let sceneSize: CGSize
    let battleConfig: BattleConfigData

    func supporterUnits(
        from configuredSupporters: [RuntimeOwnedSupporter]
    ) -> [BattleUnit] {
        configuredSupporters.enumerated().compactMap { index, supporter in
            supporterUnit(from: supporter, slot: index)
        }
    }

    private func supporterUnit(
        from supporter: RuntimeOwnedSupporter,
        slot: Int
    ) -> BattleUnit? {
        if let monster = monsters.first(where: {
            $0.id == supporter.characterId
                || $0.monsterName == supporter.imageName
        }) {
            let node = makeSprite(
                imageName: supporter.imageName,
                side: .support,
                role: .supporter,
                scaleMultiplier: supporter.scaleMultiplier ?? 1
            )

            return BattleUnit(
                node: node,
                side: .support,
                id: supporter.characterId,
                level: supporter.level,
                maxHP: 1,
                currentHP: 1,
                attack: 0,
                defense: 0,
                xOffset: scaledSupportOffset(
                    supporter.xOffset,
                    fallback: monster.xOffset - 120 + slot * 42
                ),
                yOffset: scaledSupportOffset(
                    supporter.yOffset,
                    fallback: monster.yOffset + 180 + slot * 24
                ),
                zOffset: monster.zOffset
                    + scaledSupportOffset(
                        supporter.zOffset,
                        fallback: -120 + slot * 8
                    ),
                attackBonus: supporter.attackBonus
                    ?? min(Double(monster.attack ?? 0) / 5_000, 0.18),
                defenseBonus: supporter.defenseBonus
                    ?? min(Double(monster.defense ?? 0) / 4_000, 0.14),
                healthBonus: supporter.healthBonus
                    ?? min(Double(monster.hp ?? 0) / 20_000, 0.16),
                hpRegenBonus: supporter.hpRegenBonus ?? 0,
                speedBonus: supporter.speedBonus ?? 0
            )
        }

        if let tamer = tamers.first(where: {
            $0.id == supporter.characterId
                || $0.tamerName == supporter.imageName
        }) {
            let node = makeSprite(
                imageName: supporter.imageName,
                side: .support,
                role: .supporter,
                scaleMultiplier: supporter.scaleMultiplier ?? 1
            )

            return BattleUnit(
                node: node,
                side: .support,
                id: supporter.characterId,
                level: supporter.level,
                maxHP: 1,
                currentHP: 1,
                attack: 0,
                defense: 0,
                xOffset: scaledSupportOffset(
                    supporter.xOffset,
                    fallback: tamer.xOffset - 120 + slot * 42
                ),
                yOffset: scaledSupportOffset(
                    supporter.yOffset,
                    fallback: tamer.yOffset + 180 + slot * 24
                ),
                zOffset: tamer.zOffset
                    + scaledSupportOffset(
                        supporter.zOffset,
                        fallback: -120 + slot * 8
                    ),
                attackBonus: supporter.attackBonus
                    ?? tamer.supportAttackBonus
                    ?? 0,
                defenseBonus: supporter.defenseBonus
                    ?? tamer.supportDefenseBonus
                    ?? 0,
                healthBonus: supporter.healthBonus
                    ?? tamer.supportHealthBonus
                    ?? 0,
                hpRegenBonus: supporter.hpRegenBonus ?? 0,
                speedBonus: supporter.speedBonus ?? 0
            )
        }

        let node = makeSprite(
            imageName: supporter.imageName,
            side: .support,
            role: .supporter,
            scaleMultiplier: supporter.scaleMultiplier ?? 1
        )

        return BattleUnit(
            node: node,
            side: .support,
            id: supporter.characterId,
            level: supporter.level,
            maxHP: 1,
            currentHP: 1,
            attack: 0,
            defense: 0,
            xOffset: scaledSupportOffset(
                supporter.xOffset,
                fallback: -120 + slot * 42
            ),
            yOffset: scaledSupportOffset(
                supporter.yOffset,
                fallback: -120 + slot * 24
            ),
            zOffset: scaledSupportOffset(
                supporter.zOffset,
                fallback: -120 + slot * 8
            ),
            attackBonus: supporter.attackBonus ?? 0.10,
            defenseBonus: supporter.defenseBonus ?? 0.08,
            healthBonus: supporter.healthBonus ?? 0.10,
            hpRegenBonus: supporter.hpRegenBonus ?? 0,
            speedBonus: supporter.speedBonus ?? 0
        )
    }

    private func scaledSupportOffset(
        _ explicitValue: Int?,
        fallback: Int
    ) -> Int {
        explicitValue ?? fallback
    }

    func playerUnits(from configuredMonsters: [BattleUnitConfig])
        -> [BattleUnit]
    {
        configuredMonsters
            .prefix(battleConfig.maxPlayerMonsters)
            .compactMap { unit(from: $0, side: .player) }
    }

    func supportUnits(from configuredTamers: [BattleUnitConfig]) -> [BattleUnit]
    {
        configuredTamers
            .prefix(battleConfig.maxSupportTamers)
            .compactMap { tamer(from: $0) }
    }

    func enemyUnits(from wave: BattleWaveData) -> [BattleUnit] {
        wave.enemies.compactMap {
            unit(from: $0, side: .enemy, isBoss: wave.isBossWave)
        }
    }

    func supportStats(from configuredTamers: [BattleUnitConfig])
        -> [BattleSupportStats]
    {
        configuredTamers
            .prefix(battleConfig.maxSupportTamers)
            .compactMap { config in
                guard let tamer = tamers.first(where: { $0.id == config.id })
                else {
                    return nil
                }

                return BattleStatCalculator.tamerStats(
                    from: config,
                    tamer: tamer
                )
            }
    }

    func monsterStats(from config: BattleUnitConfig) -> BattleStats? {
        guard let monster = monsters.first(where: { $0.id == config.id }) else {
            return nil
        }

        return BattleStatCalculator.monsterStats(
            from: config,
            monster: monster,
            battleConfig: battleConfig
        )
    }

    private func unit(from config: BattleUnitConfig, side: BattleSide)
        -> BattleUnit?
    {
        unit(from: config, side: side, isBoss: false)
    }

    private func unit(
        from config: BattleUnitConfig,
        side: BattleSide,
        isBoss: Bool
    )
        -> BattleUnit?
    {
        switch side {
        case .player:
            guard let monster = monsters.first(where: { $0.id == config.id })
            else {
                return nil
            }

            let stats = BattleStatCalculator.monsterStats(
                from: config,
                monster: monster,
                battleConfig: battleConfig
            )
            let node = makeSprite(
                imageName: config.imageName ?? monster.monsterName,
                side: side,
                role: .playerMonster,
                scaleMultiplier: config.scaleMultiplier ?? 1
            )
            return BattleUnit(
                node: node,
                side: side,
                id: monster.id,
                level: stats.level,
                xp: config.xp ?? 0,
                maxXP: config.maxXP ?? 1,
                maxHP: stats.maxHP,
                currentHP: stats.maxHP,
                attack: stats.attack,
                defense: stats.defense,
                xOffset: monster.xOffset,
                yOffset: monster.yOffset,
                zOffset: monster.zOffset
            )

        case .enemy:
            guard let enemy = enemies.first(where: { $0.id == config.id })
            else {
                return nil
            }

            let stats = BattleStatCalculator.enemyStats(
                from: config,
                enemy: enemy
            )
            let node = makeSprite(
                imageName: config.imageName ?? enemy.imageName
                    ?? enemy.enemyName,
                side: side,
                role: isBoss ? .boss : .enemy,
                scaleMultiplier: config.scaleMultiplier ?? 1
            )
            return BattleUnit(
                node: node,
                side: side,
                id: enemy.id,
                level: stats.level,
                maxHP: stats.maxHP,
                currentHP: stats.maxHP,
                attack: stats.attack,
                defense: stats.defense,
                xOffset: enemy.xOffset,
                yOffset: enemy.yOffset,
                zOffset: enemy.zOffset
            )

        case .support:
            return nil
        }
    }

    private func tamer(from config: BattleUnitConfig) -> BattleUnit? {
        guard let tamer = tamers.first(where: { $0.id == config.id }) else {
            return nil
        }

        let node = makeSprite(
            imageName: tamer.tamerName,
            side: .support,
            role: .tamer,
            scaleMultiplier: config.scaleMultiplier ?? 1
        )
        return BattleUnit(
            node: node,
            side: .support,
            id: tamer.id,
            level: config.level ?? 1,
            maxHP: 1,
            currentHP: 1,
            attack: 0,
            defense: 0,
            xOffset: tamer.xOffset,
            yOffset: tamer.yOffset,
            zOffset: tamer.zOffset,
            attackBonus: tamer.supportAttackBonus ?? 0,
            defenseBonus: tamer.supportDefenseBonus ?? 0,
            healthBonus: tamer.supportHealthBonus ?? 0
        )
    }

    private func makeSprite(
        imageName: String,
        side: BattleSide,
        role: BattleSpriteRole,
        scaleMultiplier: Double
    ) -> SKSpriteNode {
        let texture = BattleTextureCache.texture(named: imageName)
        let node = SKSpriteNode(texture: texture)
        node.anchorPoint = CGPoint(x: 0.5, y: 0)

        let maxHeight = sceneSize.height * maxSpriteHeightRatio(for: side)
        let textureHeight = max(texture.size().height, 1)
        let baseScale = maxHeight / textureHeight
        node.setScale(
            baseScale
                * roleScale(for: role)
                * CGFloat(scaleMultiplier)
        )

        if side == .enemy {
            node.xScale = -abs(node.xScale)
        }

        return node
    }

    private func maxSpriteHeightRatio(for side: BattleSide) -> Double {
        switch side {
        case .player:
            battleConfig.playerSpriteMaxHeightRatio ?? 0.22
        case .support:
            battleConfig.supportSpriteMaxHeightRatio ?? 0.18
        case .enemy:
            battleConfig.enemySpriteMaxHeightRatio ?? 0.22
        }
    }

    private func roleScale(for role: BattleSpriteRole) -> CGFloat {
        switch role {
        case .playerMonster:
            BattleSpriteScale.playerMonster

        case .tamer:
            BattleSpriteScale.tamer

        case .supporter:
            BattleSpriteScale.supporter

        case .enemy:
            BattleSpriteScale.enemy

        case .boss:
            BattleSpriteScale.boss
        }
    }
}

private enum BattleSpriteRole {
    case playerMonster
    case tamer
    case supporter
    case enemy
    case boss
}
