import SwiftData
import SwiftUI
import Testing
@testable import Montam

@Suite("Inventory Services")
@MainActor
struct InventoryServiceTests {
    @Test("Item shop purchase spends price and applies rewards")
    func itemShopPurchaseUpdatesSave() throws {
        let context = try makeContext()
        let save = GameSaveData(bits: 200, coins: 100, crystals: 10)
        context.insert(save)
        let product = ItemShopProductData(
            id: "test_ticket",
            title: "Ticket",
            subtitle: nil,
            titleKey: nil,
            subtitleKey: nil,
            visual: "tickets",
            badge: nil,
            priceCurrency: "bits",
            priceAmount: 120,
            sortOrder: 1,
            rewards: ShopProductRewards(
                crystals: nil,
                coins: nil,
                bits: nil,
                summonTickets: 1,
                unlockEventPass: nil
            )
        )

        let didPurchase = ShopInventoryService.purchaseItemProduct(
            product,
            saves: [save],
            modelContext: context
        )

        #expect(didPurchase)
        #expect(save.bits == 80)
        #expect(save.summonTickets == 1)
    }

    @Test("Item shop purchase fails without enough currency")
    func itemShopPurchaseRejectsInsufficientFunds() throws {
        let context = try makeContext()
        let save = GameSaveData(bits: 20)
        context.insert(save)
        let product = ItemShopProductData(
            id: "expensive_ticket",
            title: "Ticket",
            subtitle: nil,
            titleKey: nil,
            subtitleKey: nil,
            visual: "tickets",
            badge: nil,
            priceCurrency: "bits",
            priceAmount: 120,
            sortOrder: 1,
            rewards: ShopProductRewards(
                crystals: nil,
                coins: nil,
                bits: nil,
                summonTickets: 1,
                unlockEventPass: nil
            )
        )

        let didPurchase = ShopInventoryService.purchaseItemProduct(
            product,
            saves: [save],
            modelContext: context
        )

        #expect(!didPurchase)
        #expect(save.bits == 20)
        #expect(save.summonTickets == 0)
    }

    @Test("Non-consumable shop entitlement unlocks pass once")
    func nonConsumableEntitlementUnlocksPass() throws {
        let context = try makeContext()
        let save = GameSaveData()
        context.insert(save)
        let pass = ShopProductData(
            id: "event_pass",
            productId: "montam.pass.event",
            section: "pass",
            purchaseType: .nonConsumable,
            title: "Pass",
            subtitle: nil,
            titleKey: nil,
            subtitleKey: nil,
            visual: "pass",
            badge: nil,
            priceCurrency: nil,
            priceAmount: nil,
            sortOrder: 1,
            rewards: ShopProductRewards(
                crystals: nil,
                coins: nil,
                bits: nil,
                summonTickets: nil,
                unlockEventPass: true
            )
        )

        ShopInventoryService.syncEntitlements(
            productIds: ["montam.pass.event"],
            products: [pass],
            saves: [save],
            modelContext: context
        )
        ShopInventoryService.syncEntitlements(
            productIds: ["montam.pass.event"],
            products: [pass],
            saves: [save],
            modelContext: context
        )

        #expect(save.hasEventPass)
        #expect(save.ownedStoreProductIds == ["montam.pass.event"])
    }

    @Test("Summon spend supports aliases and rejects unknown currencies")
    func summonSpendUpdatesSupportedCurrencies() throws {
        let context = try makeContext()
        let save = GameSaveData(
            bits: 7,
            coins: 10,
            crystals: 5,
            summonTickets: 2
        )
        context.insert(save)

        #expect(SummonInventoryService.spend(
            cost: 1,
            currency: "ticket",
            saves: [save],
            modelContext: context
        ))
        #expect(SummonInventoryService.spend(
            cost: 3,
            currency: "crystals",
            saves: [save],
            modelContext: context
        ))
        #expect(!SummonInventoryService.spend(
            cost: 99,
            currency: "coins",
            saves: [save],
            modelContext: context
        ))
        #expect(!SummonInventoryService.spend(
            cost: 1,
            currency: "unknown",
            saves: [save],
            modelContext: context
        ))

        #expect(save.summonTickets == 1)
        #expect(save.crystals == 2)
        #expect(save.coins == 10)
    }

    @Test("Team selection keeps exactly one active monster")
    func selectingMonsterClearsOtherSelections() throws {
        let context = try makeContext()
        let cubon = OwnedMonsterData(monsterId: "cubon", isSelected: true)
        let kyron = OwnedMonsterData(monsterId: "kyron", isSelected: false)
        context.insert(cubon)
        context.insert(kyron)

        TeamInventoryService.selectMonster(
            id: "kyron",
            ownedMonsters: [cubon, kyron],
            modelContext: context
        )

        #expect(!cubon.isSelected)
        #expect(kyron.isSelected)
    }

    @Test("Summon supporter result inserts new supporter and upgrades duplicates")
    func summonSupporterResultCreatesAndUpgradesSupporter() throws {
        let context = try makeContext()
        let monster = MonsterData(
            id: "cubon",
            monsterName: "mon_cubon",
            name: "Cubon",
            rarity: nil,
            hp: 100,
            attack: 20,
            defense: 10,
            level: nil,
            xp: nil,
            monsterGrowthRate: nil,
            yOffset: 0,
            xOffset: 0,
            zOffset: 0
        )
        let result = SummonResultItem(
            title: "Cubon",
            subtitle: "Support",
            rarity: "common",
            kind: .supportCard,
            imageName: "mon_cubon",
            bannerId: "banner_montam",
            characterId: "cubon",
            isSupporter: true,
            accentColor: .blue
        )

        SummonInventoryService.applyResults(
            [result],
            monsters: [monster],
            tamers: [],
            ownedMonsters: [],
            ownedTamers: [],
            ownedSupporters: [],
            modelContext: context
        )
        let inserted = try context.fetch(FetchDescriptor<OwnedSupporterData>())
        SummonInventoryService.applyResults(
            [result],
            monsters: [monster],
            tamers: [],
            ownedMonsters: [],
            ownedTamers: [],
            ownedSupporters: inserted,
            modelContext: context
        )

        #expect(inserted.count == 1)
        #expect(inserted[0].characterId == "cubon")
        #expect(inserted[0].isMonster)
        #expect(inserted[0].isSelected)
        #expect(inserted[0].xp == 25)
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([
            GameSaveData.self,
            OwnedMonsterData.self,
            OwnedTamerData.self,
            OwnedSupporterData.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        return ModelContext(container)
    }
}
