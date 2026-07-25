//
//  RuntimeOwnedSupporter.swift
//  Montam
//
//  Created by Tufan Cakir on 25.07.26.
//

import Foundation

struct RuntimeOwnedSupporter {
    let characterId: String
    let imageName: String
    let level: Int
    let isMonster: Bool
    let xOffset: Int?
    let yOffset: Int?
    let zOffset: Int?
    let scaleMultiplier: Double?
    let attackBonus: Double?
    let defenseBonus: Double?
    let healthBonus: Double?

    init(
        characterId: String,
        imageName: String,
        level: Int,
        isMonster: Bool,
        xOffset: Int? = nil,
        yOffset: Int? = nil,
        zOffset: Int? = nil,
        scaleMultiplier: Double? = nil,
        attackBonus: Double? = nil,
        defenseBonus: Double? = nil,
        healthBonus: Double? = nil
    ) {
        self.characterId = characterId
        self.imageName = imageName
        self.level = level
        self.isMonster = isMonster
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.zOffset = zOffset
        self.scaleMultiplier = scaleMultiplier
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.healthBonus = healthBonus
    }
}
