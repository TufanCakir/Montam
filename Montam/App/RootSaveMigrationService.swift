import SwiftData

@MainActor
enum RootSaveMigrationService {
    static func migrateLegacyMonsterIds(
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        let legacyId = "starter_a"
        let currentId = "kyro"
        let legacyMonsters = ownedMonsters.filter { $0.monsterId == legacyId }

        guard !legacyMonsters.isEmpty else {
            return
        }

        if let current = ownedMonsters.first(where: { $0.monsterId == currentId }) {
            merge(legacyMonsters, into: current, modelContext: modelContext)
        } else if let legacy = legacyMonsters.first {
            legacy.monsterId = currentId
            legacyMonsters.dropFirst().forEach(modelContext.delete)
        }

        try? modelContext.save()
    }

    private static func merge(
        _ legacyMonsters: [OwnedMonsterData],
        into current: OwnedMonsterData,
        modelContext: ModelContext
    ) {
        for legacy in legacyMonsters {
            current.level = max(current.level, legacy.level)
            current.xp = max(current.xp, legacy.xp)
            current.isSelected = current.isSelected || legacy.isSelected
            modelContext.delete(legacy)
        }
    }
}
