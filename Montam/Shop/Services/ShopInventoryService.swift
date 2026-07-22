//
//  ShopInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum ShopInventoryService {
    static func applyRewards(
        from product: ShopProductData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = ensureSave(saves: saves, modelContext: modelContext)

        if let crystals = product.rewards.crystals {
            save.crystals += crystals
        }

        if let coins = product.rewards.coins {
            save.coins += coins
        }

        if let bits = product.rewards.bits {
            save.bits += bits
        }

        if let summonTickets = product.rewards.summonTickets {
            save.summonTickets += summonTickets
        }

        if product.rewards.unlockEventPass == true {
            save.hasEventPass = true
        }

        try? modelContext.save()
    }

    static func syncEntitlements(
        productIds: Set<String>,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        guard productIds.contains("montam.pass.event"), let save = saves.first
        else {
            return
        }

        save.hasEventPass = true
        try? modelContext.save()
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
