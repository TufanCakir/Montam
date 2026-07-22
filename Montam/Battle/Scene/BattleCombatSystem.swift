//
//  BattleCombatSystem.swift
//  Monster Transorfmieren
//

import Foundation

enum BattleCombatSystem {
    static func firstAliveUnit(in units: [BattleUnit]) -> BattleUnit? {
        units.first(where: \.isAlive)
    }

    static func hasAliveUnit(in units: [BattleUnit]) -> Bool {
        units.contains(where: \.isAlive)
    }

    @discardableResult
    static func applyDamage(from attacker: BattleUnit, to target: BattleUnit) -> BattleDamageResult {
        let damage = max(attacker.attack - target.defense, 1)
        target.currentHP = max(target.currentHP - damage, 0)
        return BattleDamageResult(damage: damage, didDefeatTarget: !target.isAlive)
    }
}

struct BattleDamageResult {
    let damage: Int
    let didDefeatTarget: Bool
}
