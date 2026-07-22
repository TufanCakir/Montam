import SwiftData

@MainActor
enum GiftBoxService {
    static func gifts() -> [GiftData] {
        JSONDataLoader.load("gift", as: [GiftData].self) ?? []
    }

    static func availableGifts(save: GameSaveData?) -> [GiftData] {
        let claimed = Set(save?.claimedGiftIds ?? [])
        return gifts().filter { !claimed.contains($0.id) }
    }

    static func claim(
        gift: GiftData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        guard !save.claimedGiftIds.contains(gift.id) else {
            return
        }

        apply(gift: gift, to: save)
        save.claimedGiftIds.append(gift.id)
        try? modelContext.save()
    }

    static func claimAll(
        gifts: [GiftData],
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        for gift in gifts {
            claim(gift: gift, saves: saves, modelContext: modelContext)
        }
    }

    static func clearGiftBox(
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        let allIds = gifts().map(\.id)
        save.claimedGiftIds = Array(Set(save.claimedGiftIds).union(allIds))
        try? modelContext.save()
    }

    private static func apply(gift: GiftData, to save: GameSaveData) {
        save.coins += gift.coins
        save.crystals += gift.crystals
        save.bits += gift.bits ?? 0
        save.summonTickets += gift.summonTickets ?? 0
    }
}
