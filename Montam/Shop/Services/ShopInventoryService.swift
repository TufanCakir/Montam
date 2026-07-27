//
//  ShopInventoryService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData

@MainActor
enum ShopInventoryService {
    static func purchaseItemProduct(
        _ product: ItemShopProductData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> Bool {
        let save = ensureSave(saves: saves, modelContext: modelContext)
        guard
            save.canSpend(product.priceCurrency, amount: product.priceAmount)
        else {
            return false
        }

        save.spend(product.priceCurrency, amount: product.priceAmount)
        applyRewards(product.rewards, to: save)
        try? modelContext.save()
        return true
    }

    static func purchaseSoftCurrencyProduct(
        _ product: ShopProductData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) -> Bool {
        guard product.purchaseType == .softCurrency,
            let priceCurrency = product.priceCurrency,
            let priceAmount = product.priceAmount
        else {
            return false
        }

        let save = ensureSave(saves: saves, modelContext: modelContext)
        guard
            save.canSpend(priceCurrency, amount: priceAmount)
        else {
            return false
        }

        save.spend(priceCurrency, amount: priceAmount)
        applyRewards(product.rewards, to: save)
        try? modelContext.save()
        return true
    }

    static func applyRewards(
        from product: ShopProductData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = ensureSave(saves: saves, modelContext: modelContext)
        applyRewards(product.rewards, to: save)
        if product.purchaseType == .nonConsumable {
            markOwned(productId: product.productId, in: save)
        }
        try? modelContext.save()
    }

    private static func applyRewards(
        _ rewards: ShopProductRewards,
        to save: GameSaveData
    ) {
        if let crystals = rewards.crystals {
            save.changeCurrency("crystals", by: crystals)
        }

        if let coins = rewards.coins {
            save.changeCurrency("coins", by: coins)
        }

        if let bits = rewards.bits {
            save.changeCurrency("bits", by: bits)
        }

        if let summonTickets = rewards.summonTickets {
            save.changeCurrency("summon_ticket", by: summonTickets)
        }

        if rewards.unlockEventPass == true {
            save.hasEventPass = true
        }
    }

    static func syncEntitlements(
        productIds: Set<String>,
        products: [ShopProductData],
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let entitledProducts = products.filter { product in
            product.purchaseType == .nonConsumable
                && productIds.contains(product.productId)
        }

        guard !entitledProducts.isEmpty else {
            return
        }

        let save = ensureSave(saves: saves, modelContext: modelContext)
        for product in entitledProducts {
            markOwned(productId: product.productId, in: save)
            applyNonConsumableEntitlement(from: product.rewards, to: save)
        }
        try? modelContext.save()
    }

    private static func applyNonConsumableEntitlement(
        from rewards: ShopProductRewards,
        to save: GameSaveData
    ) {
        if rewards.unlockEventPass == true {
            save.hasEventPass = true
        }
    }

    private static func markOwned(productId: String, in save: GameSaveData) {
        save.markStoreProductOwned(productId)
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
