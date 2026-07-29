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
        ownedSupporters: [OwnedSupporterData],
        modelContext: ModelContext
    ) {
        var seenSupporterIds = Set<String>()
        var didChange = false

        for supporter in ownedSupporters {
            if seenSupporterIds.insert(supporter.characterId).inserted {
                continue
            }

            modelContext.delete(supporter)
            didChange = true
        }

        if !ownedMonsters.contains(where: \.isSelected),
            let first = ownedMonsters.first
        {
            first.isSelected = true
            didChange = true
        }

        if didChange {
            try? modelContext.save()
        }
    }

    static func selectSupporter(
        id: String,
        ownedSupporters: [OwnedSupporterData],
        maxSelectedSupporters: Int,
        modelContext: ModelContext
    ) {
        guard
            let selectedSupporter = ownedSupporters.first(where: {
                $0.characterId == id
            })
        else {
            return
        }

        if selectedSupporter.isSelected {
            selectedSupporter.isSelected = false
        } else {
            let battleConfig =
                JSONDataLoader.load("battleConfig", as: BattleConfigData.self)
            let summons =
                JSONDataLoader.load("summon", as: [SummonData].self) ?? []
            let categoriesByBannerId = summons.reduce(
                into: [String: String]()
            ) { result, summon in
                result[summon.id] = summon.category
            }
            let selectedCategory = supportCategory(
                for: selectedSupporter,
                categoriesByBannerId: categoriesByBannerId
            )
            let selected = ownedSupporters.filter(\.isSelected)
            let categoryLimit = supportLimit(
                for: selectedCategory,
                battleConfig: battleConfig
            )
            let selectedInCategory = selected.filter {
                supportCategory(
                    for: $0,
                    categoriesByBannerId: categoriesByBannerId
                ) == selectedCategory
            }

            if selectedInCategory.count >= categoryLimit,
                let oldestCategorySelection = selectedInCategory.first
            {
                oldestCategorySelection.isSelected = false
            } else if selected.count >= max(maxSelectedSupporters, 1),
                let oldestSelection = selected.first
            {
                oldestSelection.isSelected = false
            }

            selectedSupporter.isSelected = true
        }

        try? modelContext.save()
    }

    private static func supportCategory(
        for supporter: OwnedSupporterData,
        categoriesByBannerId: [String: String]
    ) -> String {
        categoriesByBannerId[supporter.bannerId]
            ?? "montam"
    }

    private static func supportLimit(
        for category: String,
        battleConfig: BattleConfigData?
    ) -> Int {
        switch category {
        case "tamer":
            return battleConfig?.maxTamerSupporters ?? 1
        case "mega_supporter":
            return battleConfig?.maxMegaSupporters ?? 1
        default:
            return battleConfig?.maxMontamSupporters ?? 1
        }
    }

    static func selectMonster(
        id: String,
        imageName: String? = nil,
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        guard let selectedMonster = ownedMonsters.first(where: {
            $0.monsterId == id
        }) else {
            return
        }

        for monster in ownedMonsters {
            monster.isSelected = monster.monsterId == id
        }
        selectedMonster.isSelected = true
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
