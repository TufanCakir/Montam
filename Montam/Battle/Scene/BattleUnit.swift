//
//  BattleUnit.swift
//  Monster Transorfmieren
//

import SpriteKit

final class BattleUnit {
    let node: SKSpriteNode
    let side: BattleSide
    let id: String
    var level: Int
    var maxHP: Int
    var currentHP: Int
    var attack: Int
    var defense: Int
    let attackBonus: Double
    let defenseBonus: Double
    let healthBonus: Double

    var isAlive: Bool {
        currentHP > 0
    }

    init(
        node: SKSpriteNode,
        side: BattleSide,
        id: String,
        level: Int,
        maxHP: Int,
        currentHP: Int,
        attack: Int,
        defense: Int,
        attackBonus: Double = 0,
        defenseBonus: Double = 0,
        healthBonus: Double = 0
    ) {
        self.node = node
        self.side = side
        self.id = id
        self.level = level
        self.maxHP = maxHP
        self.currentHP = currentHP
        self.attack = attack
        self.defense = defense
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.healthBonus = healthBonus
    }
}
