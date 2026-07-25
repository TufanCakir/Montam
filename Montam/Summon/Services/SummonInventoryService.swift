//
//  SummonInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum SummonInventoryService {
    static func spend(
        cost: Int,
        currency: String,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> Bool {
        guard cost > 0 else {
            return true
        }

        let save = ensureSave(saves: saves, modelContext: modelContext)

        switch currency {
        case "crystal", "crystals":
            guard save.crystals >= cost else { return false }
            save.crystals -= cost
        case "summon_ticket", "ticket", "tickets":
            guard save.summonTickets >= cost else { return false }
            save.summonTickets -= cost
        case "bit", "bits":
            guard save.bits >= cost else { return false }
            save.bits -= cost
        case "coin", "coins":
            guard save.coins >= cost else { return false }
            save.coins -= cost
        default:
            return false
        }

        try? modelContext.save()
        return true
    }

    static func applyResults(
        _ results: [SummonResultItem],
        monsters: [MonsterData],
        tamers: [TamerData],
        ownedMonsters: [OwnedMonsterData],
        ownedTamers: [OwnedTamerData],
        ownedSupporters: [OwnedSupporterData],
        modelContext: ModelContext
    ) {
        var supporterCache: [String: OwnedSupporterData] = [:]
        for supporter in ownedSupporters
        where supporterCache[supporter.characterId] == nil {
            supporterCache[supporter.characterId] = supporter
        }

        for result in results {
            if result.isSupporter {
                applySupporterResult(
                    result,
                    monsters: monsters,
                    tamers: tamers,
                    ownedSupporters: &supporterCache,
                    modelContext: modelContext
                )
                continue
            }

            switch result.kind {
            case .monster:
                guard
                    let monster = monsters.first(where: {
                        $0.monsterName == result.imageName
                            || $0.name == result.title
                    })
                else {
                    continue
                }

                let owned =
                    ownedMonsters.first { $0.monsterId == monster.id }
                    ?? OwnedMonsterData(monsterId: monster.id)

                if owned.modelContext == nil {
                    modelContext.insert(owned)
                } else {
                    owned.xp += 25
                }
            case .tamer:
                guard
                    let tamer = tamers.first(where: {
                        $0.tamerName == result.imageName
                            || $0.name == result.title
                    })
                else {
                    continue
                }

                let owned =
                    ownedTamers.first { $0.tamerId == tamer.id }
                    ?? OwnedTamerData(tamerId: tamer.id)

                if owned.modelContext == nil {
                    modelContext.insert(owned)
                } else {
                    owned.xp += 25
                }
            case .supportCard:
                continue
            }
        }

        try? modelContext.save()
    }

    private static func applySupporterResult(
        _ result: SummonResultItem,
        monsters: [MonsterData],
        tamers: [TamerData],
        ownedSupporters: inout [String: OwnedSupporterData],
        modelContext: ModelContext
    ) {
        guard
            let characterId = result.characterId,
            let imageName = result.imageName
        else {
            return
        }

        let isTamer = tamers.contains {
            $0.id == characterId
                || $0.tamerName == imageName
                || $0.name == result.title
        }
        let isMonster =
            !isTamer
            || monsters.contains {
                $0.id == characterId
                    || $0.monsterName == imageName
                    || $0.name == result.title
            }

        let owned =
            ownedSupporters[characterId]
            ?? OwnedSupporterData(
                bannerId: result.bannerId ?? "",
                characterId: characterId,
                imageName: imageName,
                isMonster: isMonster,
                isSelected: !ownedSupporters.values.contains(where: \.isSelected)
            )

        if owned.modelContext == nil {
            modelContext.insert(owned)
            ownedSupporters[characterId] = owned
        } else {
            owned.xp += 25
            owned.bannerId = result.bannerId ?? owned.bannerId
            owned.imageName = imageName
            owned.isMonster = isMonster
        }
    }

    private static func ensureSave(
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> GameSaveData {
        if let save = saves.first {
            return save
        }

        let save = GameSaveData(didCompleteOnboarding: true)
        modelContext.insert(save)
        return save
    }
}
