//
//  BattleUnitFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit

struct BattleUnitFactory {
    let monsters: [MonsterData]
    let tamers: [TamerData]
    let enemies: [EnemyData]
    let sceneSize: CGSize
    let battleConfig: BattleConfigData

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
        wave.enemies.compactMap { unit(from: $0, side: .enemy) }
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
                scaleMultiplier: config.scaleMultiplier ?? 1
            )
            return BattleUnit(
                node: node,
                side: side,
                id: monster.id,
                level: stats.level,
                maxHP: stats.maxHP,
                currentHP: stats.maxHP,
                attack: stats.attack,
                defense: stats.defense
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
                imageName: enemy.enemyName,
                side: side,
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
                defense: stats.defense
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
            scaleMultiplier: config.scaleMultiplier ?? 0.82
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
            attackBonus: tamer.supportAttackBonus ?? 0,
            defenseBonus: tamer.supportDefenseBonus ?? 0,
            healthBonus: tamer.supportHealthBonus ?? 0
        )
    }

    private func makeSprite(
        imageName: String,
        side: BattleSide,
        scaleMultiplier: Double
    ) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imageName)
        let node = SKSpriteNode(texture: texture)
        node.anchorPoint = CGPoint(x: 0.5, y: 0)

        let maxHeight = sceneSize.height * maxSpriteHeightRatio(for: side)
        let textureHeight = max(texture.size().height, 1)
        let baseScale = maxHeight / textureHeight
        node.setScale(baseScale * CGFloat(scaleMultiplier))

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
}
