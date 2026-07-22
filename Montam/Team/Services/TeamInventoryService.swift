//
//  TeamInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

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
        guard
            let active = ownedMonsters.first(where: {
                $0.monsterId == evolution.sourceMonsterId && $0.isSelected
            }),
            active.level >= evolution.requiredLevel
        else {
            return
        }

        if let existingTarget = ownedMonsters.first(where: {
            $0.monsterId == evolution.targetMonsterId
        }) {
            existingTarget.level = max(existingTarget.level, active.level)
            existingTarget.xp = max(existingTarget.xp, active.xp)
            existingTarget.isSelected = true
            existingTarget.equippedImageName = evolution.targetImageName
            active.isSelected = false
        } else {
            active.monsterId = evolution.targetMonsterId
            active.equippedImageName = evolution.targetImageName
            active.isSelected = true
        }

        try? modelContext.save()
    }

    static func equipAppearance(
        imageName: String,
        monsterId: String,
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        guard
            let monster = ownedMonsters.first(where: {
                $0.monsterId == monsterId
            })
        else {
            return
        }

        monster.equippedImageName = imageName
        try? modelContext.save()
    }
}
