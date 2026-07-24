//
//  BattleUnitFactory.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit
import UIKit

enum BattleSpriteScale {
    static let playerMonster: CGFloat = 0.50
    static let tamer: CGFloat = 0.50
    static let enemy: CGFloat = 0.50
    static let boss: CGFloat = 0.80
}

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
                imageName: config.imageName ?? enemy.imageName ?? enemy.enemyName,
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
        let texture = Self.texture(named: imageName)
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

    private static func texture(named imageName: String) -> SKTexture {
        let cachedURL = RemoteContentService.cachedAssetURL(named: imageName)
        if FileManager.default.fileExists(atPath: cachedURL.path()),
            let image = UIImage(contentsOfFile: cachedURL.path())
        {
            return SKTexture(image: image)
        }

        return SKTexture(imageNamed: imageName)
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
    case enemy
    case boss
}
