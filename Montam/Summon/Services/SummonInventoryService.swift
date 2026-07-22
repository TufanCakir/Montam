//
//  SummonInventoryService.swift
//  Monster Transorfmieren
//

import SwiftData

@MainActor
enum SummonInventoryService {
    static func spend(cost: Int, currency: String, saves: [GameSaveData], modelContext: ModelContext) -> Bool {
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
        modelContext: ModelContext
    ) {
        for result in results {
            switch result.kind {
            case .monster:
                guard let monster = monsters.first(where: { $0.monsterName == result.imageName || $0.name == result.title }) else {
                    continue
                }

                let owned = ownedMonsters.first { $0.monsterId == monster.id } ?? OwnedMonsterData(monsterId: monster.id)

                if owned.modelContext == nil {
                    modelContext.insert(owned)
                } else {
                    owned.xp += 25
                }
            case .tamer:
                guard let tamer = tamers.first(where: { $0.tamerName == result.imageName || $0.name == result.title }) else {
                    continue
                }

                let owned = ownedTamers.first { $0.tamerId == tamer.id } ?? OwnedTamerData(tamerId: tamer.id)

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

    private static func ensureSave(saves: [GameSaveData], modelContext: ModelContext) -> GameSaveData {
        if let save = saves.first {
            return save
        }

        let save = GameSaveData(didCompleteOnboarding: true)
        modelContext.insert(save)
        return save
    }
}
