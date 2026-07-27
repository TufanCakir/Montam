//
//  TradeInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum TradeInventoryService {
    static func canTrade(_ offer: TradeOfferData, save: GameSaveData?) -> Bool {
        save?.canSpend(offer.costCurrency, amount: offer.costAmount) ?? false
    }

    static func performTrade(
        _ offer: TradeOfferData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> String {
        guard canTrade(offer, save: saves.first) else {
            return "Nicht genug \(GameCurrency.title(for: offer.costCurrency))."
        }

        change(
            offer.costCurrency,
            by: -offer.costAmount,
            saves: saves,
            modelContext: modelContext
        )
        change(
            offer.rewardCurrency,
            by: offer.rewardAmount,
            saves: saves,
            modelContext: modelContext
        )
        try? modelContext.save()
        return "Tausch abgeschlossen."
    }

    private static func change(
        _ currency: String,
        by amount: Int,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = ensureSave(saves: saves, modelContext: modelContext)
        save.changeCurrency(currency, by: amount)
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
