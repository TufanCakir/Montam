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
            canSpend(
                currency: product.priceCurrency,
                amount: product.priceAmount,
                from: save
            )
        else {
            return false
        }

        spend(
            currency: product.priceCurrency,
            amount: product.priceAmount,
            from: save
        )
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
            canSpend(
                currency: priceCurrency,
                amount: priceAmount,
                from: save
            )
        else {
            return false
        }

        spend(currency: priceCurrency, amount: priceAmount, from: save)
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
            save.crystals += crystals
        }

        if let coins = rewards.coins {
            save.coins += coins
        }

        if let bits = rewards.bits {
            save.bits += bits
        }

        if let summonTickets = rewards.summonTickets {
            save.summonTickets += summonTickets
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
        guard !save.ownedStoreProductIds.contains(productId) else {
            return
        }

        save.ownedStoreProductIds.append(productId)
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

    private static func canSpend(
        currency: String,
        amount: Int,
        from save: GameSaveData
    ) -> Bool {
        switch GameCurrency.normalized(currency) {
        case "coins":
            return save.coins >= amount
        case "crystals":
            return save.crystals >= amount
        case "bits":
            return save.bits >= amount
        case "summon_ticket":
            return save.summonTickets >= amount
        default:
            return false
        }
    }

    private static func spend(
        currency: String,
        amount: Int,
        from save: GameSaveData
    ) {
        switch GameCurrency.normalized(currency) {
        case "coins":
            save.coins -= amount
        case "crystals":
            save.crystals -= amount
        case "bits":
            save.bits -= amount
        case "summon_ticket":
            save.summonTickets -= amount
        default:
            return
        }
    }
}
