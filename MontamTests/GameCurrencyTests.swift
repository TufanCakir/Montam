import Testing
@testable import Montam

@Suite("Game Currency")
struct GameCurrencyTests {
    @Test("Normalizes supported currency aliases")
    func normalizesCurrencyAliases() {
        #expect(GameCurrency.normalized(" coin ") == "coins")
        #expect(GameCurrency.normalized("CRYSTAL") == "crystals")
        #expect(GameCurrency.normalized("tickets") == "summon_ticket")
        #expect(GameCurrency.normalized("xp") == "exp")
        #expect(GameCurrency.normalized("custom") == "custom")
    }

    @Test("Save amounts, spending, and rewards update the right buckets")
    @MainActor
    func updatesSaveCurrencyBuckets() {
        let save = GameSaveData(
            bits: 7,
            coins: 20,
            crystals: 2,
            summonTickets: 1
        )

        #expect(save.amount(for: "coin") == 20)
        #expect(save.canSpend("coins", amount: 15))
        #expect(!save.canSpend("coins", amount: 25))
        #expect(!save.canSpend("unknown", amount: 1))
        #expect(save.spend("coins", amount: 5))

        GameCurrency.apply(
            RewardData(id: "reward_bits", resourceId: "bit", amount: 3),
            to: save
        )
        GameCurrency.apply(
            RewardData(
                id: "reward_tickets",
                resourceId: "ticket",
                amount: 2
            ),
            to: save
        )

        #expect(save.coins == 15)
        #expect(save.bits == 10)
        #expect(save.summonTickets == 3)
    }

    @Test("Store products are only marked owned once")
    @MainActor
    func storeProductOwnershipIsUnique() {
        let save = GameSaveData()

        #expect(save.markStoreProductOwned("montam.pass.event"))
        #expect(!save.markStoreProductOwned("montam.pass.event"))
        #expect(save.ownedStoreProductIds == ["montam.pass.event"])
    }
}
