//
//  EventRewardService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum EventRewardService {
    static func applyRewards(
        from event: EventData,
        saves: [GameSaveData],
        ownedMonsters: [OwnedMonsterData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)
        let progression =
            JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
            ?? GameProgressionData()
        let monsterCatalog =
            JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        for reward in event.rewards {
            switch GameCurrency.normalized(reward.currency) {
            case "exp":
                applyXP(
                    reward.amount,
                    to: ownedMonsters,
                    progression: progression
                )
            default:
                save.changeCurrency(reward.currency, by: reward.amount)
            }
        }

        refreshPlayerStats(
            save: save,
            ownedMonsters: ownedMonsters,
            monsterCatalog: monsterCatalog,
            progression: progression
        )
        try? modelContext.save()
    }

    private static func applyXP(
        _ amount: Int,
        to ownedMonsters: [OwnedMonsterData],
        progression: GameProgressionData
    ) {
        guard amount > 0 else {
            return
        }

        for monster in ownedMonsters where monster.isSelected {
            monster.xp += amount
            while monster.level < progression.resolvedMaxLevel
                && monster.xp
                    >= GameProgressionCalculator.xpNeeded(
                        for: monster.level,
                        progression: progression
                    )
            {
                monster.xp -= GameProgressionCalculator.xpNeeded(
                    for: monster.level,
                    progression: progression
                )
                monster.level += 1
            }
        }
    }

    private static func refreshPlayerStats(
        save: GameSaveData,
        ownedMonsters: [OwnedMonsterData],
        monsterCatalog: [MonsterData],
        progression: GameProgressionData
    ) {
        let selected = ownedMonsters.filter(\.isSelected)
        save.playerLevel = selected.map(\.level).max() ?? save.playerLevel
        save.playerXP = selected.first?.xp ?? save.playerXP
        save.playerMaxXP = GameProgressionCalculator.xpNeeded(
            for: save.playerLevel,
            progression: progression
        )
        save.playerPower = selected.reduce(0) { total, owned in
            guard
                let monster = monsterCatalog.first(where: {
                    $0.id == owned.monsterId
                })
            else {
                return total
            }

            return total
                + GameProgressionCalculator.power(
                    for: monster,
                    level: owned.level
                )
        }
    }
}
