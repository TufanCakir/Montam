//
//  RootSaveMigrationService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum RootSaveMigrationService {
    static func migrateLegacyMonsterIds(
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        let legacyIds: Set<String> = ["starter_a", "kyron", "cubmon"]
        let currentId = "cubon"
        let legacyMonsters = ownedMonsters.filter {
            legacyIds.contains($0.monsterId)
        }

        guard !legacyMonsters.isEmpty else {
            return
        }

        if let current = ownedMonsters.first(where: {
            $0.monsterId == currentId
        }) {
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
            current.equippedImageName =
                current.equippedImageName ?? legacy.equippedImageName
            modelContext.delete(legacy)
        }
    }
}
