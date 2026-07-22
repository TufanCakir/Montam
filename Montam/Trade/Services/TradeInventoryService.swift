import SwiftData

@MainActor
enum TradeInventoryService {
    static func canTrade(_ offer: TradeOfferData, save: GameSaveData?) -> Bool {
        amount(for: offer.costCurrency, save: save) >= offer.costAmount
    }

    static func performTrade(
        _ offer: TradeOfferData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> String {
        guard canTrade(offer, save: saves.first) else {
            return "Nicht genug \(GameCurrency.title(for: offer.costCurrency))."
        }

        change(offer.costCurrency, by: -offer.costAmount, saves: saves, modelContext: modelContext)
        change(offer.rewardCurrency, by: offer.rewardAmount, saves: saves, modelContext: modelContext)
        try? modelContext.save()
        return "Tausch abgeschlossen."
    }

    private static func amount(for currency: String, save: GameSaveData?) -> Int {
        guard let save else {
            return 0
        }

        return switch GameCurrency.normalized(currency) {
        case "coins": save.coins
        case "crystals": save.crystals
        case "summon_ticket": save.summonTickets
        case "bits": save.bits
        default: 0
        }
    }

    private static func change(
        _ currency: String,
        by amount: Int,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = ensureSave(saves: saves, modelContext: modelContext)

        switch GameCurrency.normalized(currency) {
        case "coins": save.coins += amount
        case "crystals": save.crystals += amount
        case "summon_ticket": save.summonTickets += amount
        case "bits": save.bits += amount
        default: break
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
