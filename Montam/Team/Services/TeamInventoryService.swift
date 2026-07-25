//
//  TeamInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum TeamInventoryService {
    static func syncJSONCompanions(
        ownedMonsters: [OwnedMonsterData],
        ownedTamers: [OwnedTamerData],
        modelContext: ModelContext
    ) {
        let monsters =
            JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
        let tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
        let ownedMonsterIds = Set(ownedMonsters.map(\.monsterId))
        let ownedTamerIds = Set(ownedTamers.map(\.tamerId))
        var didChange = false

        for (index, monster) in monsters.enumerated()
        where !ownedMonsterIds.contains(monster.id) {
            modelContext.insert(
                OwnedMonsterData(
                    monsterId: monster.id,
                    level: 1,
                    xp: 0,
                    isSelected: ownedMonsters.isEmpty && index == 0,
                    equippedImageName: monster.monsterName
                )
            )
            didChange = true
        }

        for (index, tamer) in tamers.enumerated()
        where !ownedTamerIds.contains(tamer.id) {
            modelContext.insert(
                OwnedTamerData(
                    tamerId: tamer.id,
                    level: 1,
                    xp: 0,
                    isSelected: ownedTamers.isEmpty && index == 0
                )
            )
            didChange = true
        }

        if !ownedMonsters.contains(where: \.isSelected),
            let first = ownedMonsters.first
        {
            first.isSelected = true
            didChange = true
        }

        if !ownedTamers.contains(where: \.isSelected),
            let first = ownedTamers.first
        {
            first.isSelected = true
            didChange = true
        }

        if didChange {
            try? modelContext.save()
        }
    }

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
