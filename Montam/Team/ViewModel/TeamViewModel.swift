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
    let displayName: String
    let rarity: String
    let level: Int
    let xp: Int
    let maxXP: Int
    let power: Int
    let isSelected: Bool
    let appearances: [TeamAppearanceRow]
    let equippedImageName: String
}

struct TeamAppearanceRow: Identifiable, Equatable {
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
    let targetAppearance: TeamAppearanceRow
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
                let monster = monsters.first(where: { $0.id == owned.monsterId })
            else {
                return nil
            }

            let equippedImageName =
                owned.equippedImageName ?? defaultAppearance(for: monster)?.imageName
                ?? monster.monsterName
            let activeAppearance = appearance(for: equippedImageName)

            return TeamMonsterRow(
                id: monster.id,
                imageName: equippedImageName,
                name: monster.name,
                displayName: activeAppearance?.title ?? monster.name,
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
            let monster = monsters.first(where: { $0.id == active.monsterId })
        else {
            return nil
        }

        let equippedImageName =
            active.equippedImageName ?? defaultAppearance(for: monster)?.imageName
            ?? monster.monsterName
        let source = evolutionAppearances(
            for: monster,
            equippedImageName: equippedImageName
        )
        let currentIndex = currentEvolutionIndex(
            in: source,
            equippedImageName: equippedImageName,
            level: active.level
        )
        let targetIndex = min(currentIndex + 1, source.count - 1)

        guard source.indices.contains(targetIndex), targetIndex > currentIndex else {
            return nil
        }

        let target = source[targetIndex]
        let targetRow = TeamAppearanceRow(
            id: target.id,
            title: target.title,
            imageName: target.imageName,
            requiredLevel: target.requiredLevel ?? 1,
            isEquipped: target.imageName == equippedImageName,
            isUnlocked: active.level >= (target.requiredLevel ?? 1)
        )

        return TeamEvolutionState(
            targetAppearance: targetRow,
            canEvolve: targetRow.isUnlocked,
            currentLevel: active.level
        )
    }

    func activeMonsterImageName(ownedMonsters: [OwnedMonsterData]) -> String? {
        guard let active = ownedMonsters.first(where: \.isSelected),
            let monster = monsters.first(where: { $0.id == active.monsterId })
        else {
            return nil
        }

        return active.equippedImageName ?? defaultAppearance(for: monster)?.imageName
            ?? monster.monsterName
    }

    private func appearanceRows(
        monster: MonsterData,
        level: Int,
        equippedImageName: String
    ) -> [TeamAppearanceRow] {
        appearanceSource(for: monster, equippedImageName: equippedImageName).map { item in
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

    private func appearanceSource(
        for monster: MonsterData,
        equippedImageName: String? = nil
    ) -> [MonsterAppearanceData] {
        let configured = appearances
            .filter { $0.monsterId == monster.id }
            .sorted { ($0.requiredLevel ?? 1) < ($1.requiredLevel ?? 1) }

        if !configured.isEmpty {
            return configured
        }

        if let equippedImageName,
           let equippedAppearance = appearance(for: equippedImageName)
        {
            let lineage = appearances
                .filter { $0.monsterId == equippedAppearance.monsterId }
                .sorted { ($0.requiredLevel ?? 1) < ($1.requiredLevel ?? 1) }
            if !lineage.isEmpty {
                return lineage
            }
        }

        guard configured.isEmpty else {
            return configured
        }

        return [
            MonsterAppearanceData(
                id: "\(monster.id)_default",
                monsterId: monster.id,
                title: monster.name,
                imageName: monster.monsterName,
                requiredLevel: 1,
                isDefault: true,
                isEvolutionStep: true
            )
        ]
    }

    private func evolutionAppearances(
        for monster: MonsterData,
        equippedImageName: String
    ) -> [MonsterAppearanceData] {
        appearanceSource(for: monster, equippedImageName: equippedImageName)
            .filter { $0.isEvolutionStep != false }
    }

    private func defaultAppearance(for monster: MonsterData) -> MonsterAppearanceData? {
        appearanceSource(for: monster).first { $0.isDefault == true }
            ?? appearanceSource(for: monster).first
    }

    private func appearance(for imageName: String) -> MonsterAppearanceData? {
        appearances.first { $0.imageName == imageName }
    }

    private func currentEvolutionIndex(
        in source: [MonsterAppearanceData],
        equippedImageName: String,
        level: Int
    ) -> Int {
        if let exact = source.firstIndex(where: { $0.imageName == equippedImageName }) {
            return exact
        }

        return source.lastIndex { level >= ($0.requiredLevel ?? 1) } ?? 0
    }
}
