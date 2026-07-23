//
//  TeamMonsterRow.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Observation

struct TeamMonsterRow: Identifiable {
    let id: String
    let imageName: String
    let name: String
    let rarity: String
    let level: Int
    let xp: Int
    let maxXP: Int
    let power: Int
    let isSelected: Bool
    let appearances: [TeamAppearanceRow]
    let equippedImageName: String
}

struct TeamAppearanceRow: Identifiable {
    let id: String
    let title: String
    let imageName: String
    let requiredLevel: Int
    let isEquipped: Bool
    let isUnlocked: Bool
}

struct TeamTamerRow: Identifiable {
    let id: String
    let imageName: String
    let name: String
    let rarity: String
    let level: Int
    let attackBonus: Double
    let defenseBonus: Double
    let healthBonus: Double
    let isSelected: Bool
}

struct TeamEvolutionState {
    let evolution: EvolutionData
    let canEvolve: Bool
    let currentLevel: Int
}

struct TeamEvolutionPreview: Equatable {
    let sourceImageName: String
    let targetImageName: String
    let targetName: String
}

@Observable
final class TeamViewModel {
    private let monsters =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let tamers =
        JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
    private let evolutions =
        JSONDataLoader.load("evolution", as: [EvolutionData].self) ?? []
    private let appearances =
        JSONDataLoader.load(
            "monsterAppearance",
            as: [MonsterAppearanceData].self
        ) ?? []
    private let progression =
        JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
        ?? GameProgressionData()

    func monsterRows(ownedMonsters: [OwnedMonsterData]) -> [TeamMonsterRow] {
        ownedMonsters.compactMap { owned in
            guard
                let monster = monsters.first(where: { $0.id == owned.monsterId }
                )
            else {
                return nil
            }

            let equippedImageName =
                owned.equippedImageName ?? monster.monsterName

            return TeamMonsterRow(
                id: monster.id,
                imageName: equippedImageName,
                name: monster.name,
                rarity: monster.rarity ?? "normal",
                level: owned.level,
                xp: owned.xp,
                maxXP: GameProgressionCalculator.xpNeeded(
                    for: owned.level,
                    progression: progression
                ),
                power: GameProgressionCalculator.power(
                    for: monster,
                    level: owned.level
                ),
                isSelected: owned.isSelected,
                appearances: appearanceRows(
                    monster: monster,
                    level: owned.level,
                    equippedImageName: equippedImageName
                ),
                equippedImageName: equippedImageName
            )
        }
        .sorted { lhs, rhs in
            if lhs.isSelected != rhs.isSelected {
                return lhs.isSelected
            }
            return lhs.power > rhs.power
        }
    }

    private func appearanceRows(
        monster: MonsterData,
        level: Int,
        equippedImageName: String
    ) -> [TeamAppearanceRow] {
        let configured = appearances.filter { $0.monsterId == monster.id }
        let source =
            configured.isEmpty
            ? [
                MonsterAppearanceData(
                    id: "\(monster.id)_default",
                    monsterId: monster.id,
                    title: monster.name,
                    imageName: monster.monsterName,
                    requiredLevel: 1,
                    isDefault: true
                )
            ]
            : configured

        return source.map { item in
            let requiredLevel = item.requiredLevel ?? 1
            return TeamAppearanceRow(
                id: item.id,
                title: item.title,
                imageName: item.imageName,
                requiredLevel: requiredLevel,
                isEquipped: item.imageName == equippedImageName,
                isUnlocked: level >= requiredLevel
            )
        }
    }

    func tamerRows(ownedTamers: [OwnedTamerData]) -> [TeamTamerRow] {
        ownedTamers.compactMap { owned in
            guard let tamer = tamers.first(where: { $0.id == owned.tamerId })
            else {
                return nil
            }

            return TeamTamerRow(
                id: tamer.id,
                imageName: tamer.tamerName,
                name: tamer.name,
                rarity: tamer.rarity ?? "normal",
                level: owned.level,
                attackBonus: tamer.supportAttackBonus ?? 0,
                defenseBonus: tamer.supportDefenseBonus ?? 0,
                healthBonus: tamer.supportHealthBonus ?? 0,
                isSelected: owned.isSelected
            )
        }
        .sorted { lhs, rhs in
            if lhs.isSelected != rhs.isSelected {
                return lhs.isSelected
            }
            return lhs.level > rhs.level
        }
    }

    func availableEvolution(ownedMonsters: [OwnedMonsterData])
        -> TeamEvolutionState?
    {
        guard let active = ownedMonsters.first(where: \.isSelected),
            let evolution = evolutions.first(where: {
                $0.sourceMonsterId == active.monsterId
            })
        else {
            return nil
        }

        return TeamEvolutionState(
            evolution: evolution,
            canEvolve: active.level >= evolution.requiredLevel,
            currentLevel: active.level
        )
    }

    func activeMonsterImageName(ownedMonsters: [OwnedMonsterData]) -> String? {
        guard let active = ownedMonsters.first(where: \.isSelected),
            let monster = monsters.first(where: { $0.id == active.monsterId })
        else {
            return nil
        }

        return active.equippedImageName ?? monster.monsterName
    }
}
