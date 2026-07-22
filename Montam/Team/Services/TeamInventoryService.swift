import SwiftData

@MainActor
enum TeamInventoryService {
    static func selectMonster(
        id: String,
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        for monster in ownedMonsters {
            monster.isSelected = monster.monsterId == id
        }
        try? modelContext.save()
    }

    static func selectTamer(
        id: String,
        ownedTamers: [OwnedTamerData],
        modelContext: ModelContext
    ) {
        for tamer in ownedTamers {
            tamer.isSelected = tamer.tamerId == id
        }
        try? modelContext.save()
    }

    static func evolveActiveMonster(
        _ evolution: EvolutionData,
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        guard let active = ownedMonsters.first(where: { $0.monsterId == evolution.sourceMonsterId && $0.isSelected }),
              active.level >= evolution.requiredLevel
        else {
            return
        }

        if let existingTarget = ownedMonsters.first(where: { $0.monsterId == evolution.targetMonsterId }) {
            existingTarget.level = max(existingTarget.level, active.level)
            existingTarget.xp = max(existingTarget.xp, active.xp)
            existingTarget.isSelected = true
            active.isSelected = false
        } else {
            active.monsterId = evolution.targetMonsterId
            active.isSelected = true
        }

        try? modelContext.save()
    }
}
