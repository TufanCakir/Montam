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
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        for reward in event.rewards {
            switch GameCurrency.normalized(reward.currency) {
            case "coins":
                save.coins += reward.amount
            case "crystals":
                save.crystals += reward.amount
            case "summon_ticket":
                save.summonTickets += reward.amount
            case "bits":
                save.bits += reward.amount
            default:
                break
            }
        }

        try? modelContext.save()
    }
}
