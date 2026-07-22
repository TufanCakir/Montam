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

@Observable
final class TeamViewModel {
    private let monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
    private let evolutions = JSONDataLoader.load("evolution", as: [EvolutionData].self) ?? []
    private let progression = JSONDataLoader.load("battleConfig", as: GameProgressionData.self) ?? GameProgressionData()

    func monsterRows(ownedMonsters: [OwnedMonsterData]) -> [TeamMonsterRow] {
        ownedMonsters.compactMap { owned in
            guard let monster = monsters.first(where: { $0.id == owned.monsterId }) else {
                return nil
            }

            return TeamMonsterRow(
                id: monster.id,
                imageName: monster.monsterName,
                name: monster.name,
                rarity: monster.rarity ?? "normal",
                level: owned.level,
                xp: owned.xp,
                maxXP: GameProgressionCalculator.xpNeeded(for: owned.level, progression: progression),
                power: GameProgressionCalculator.power(for: monster, level: owned.level),
                isSelected: owned.isSelected
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
            guard let tamer = tamers.first(where: { $0.id == owned.tamerId }) else {
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

    func availableEvolution(ownedMonsters: [OwnedMonsterData]) -> TeamEvolutionState? {
        guard let active = ownedMonsters.first(where: \.isSelected),
              let evolution = evolutions.first(where: { $0.sourceMonsterId == active.monsterId })
        else {
            return nil
        }

        return TeamEvolutionState(
            evolution: evolution,
            canEvolve: active.level >= evolution.requiredLevel,
            currentLevel: active.level
        )
    }
}
