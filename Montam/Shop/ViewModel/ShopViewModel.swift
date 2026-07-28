//
//  ShopViewModel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Observation

enum ShopSection: CaseIterable, Identifiable {
    case pass
    case premiumCurrency
    case item

    var id: Self { self }

    var tabTitle: String {
        switch self {
        case .pass: AppLocalizationService.text("shop.tab.pass")
        case .premiumCurrency:
            AppLocalizationService.text("shop.tab.premiumCurrency")
        case .item: AppLocalizationService.text("shop.tab.item")
        }
    }

    var jsonKey: String {
        switch self {
        case .pass: "pass"
        case .premiumCurrency: "premiumCurrency"
        case .item: "item"
        }
    }
}

enum ShopProductVisual {
    case diamonds
    case bits
    case emeralds
    case tickets
    case farm
    case resource(String)
}

struct ShopStoreProductCardState {
    let product: ShopProductData
    let visual: ShopProductVisual
    let title: String
    let subtitle: String
    let price: String
    let soldOut: Bool
    let storeUnavailable: Bool
    let storeLoading: Bool
}

struct ShopItemProductCardState {
    let product: ItemShopProductData
    let visual: ShopProductVisual
    let title: String
    let subtitle: String
    let priceCurrency: String
    let priceAmount: Int
}

@MainActor
@Observable
final class ShopViewModel {
    var selectedSection = ShopSection.premiumCurrency
    var products: [ShopProductData] = []
    var itemProducts: [ItemShopProductData] = []
    var purchaseMessage: String?

    var selectedProducts: [ShopProductData] {
        products.filter { $0.section == selectedSection.jsonKey }
    }

    var selectedEmptyTitle: String {
        switch selectedSection {
        case .pass:
            AppLocalizationService.text("shop.empty.pass")
        case .premiumCurrency:
            AppLocalizationService.text("shop.empty.premiumCurrency")
        case .item:
            AppLocalizationService.text("shop.empty.item")
        }
    }

    func loadIfNeeded(store: StoreKitShopManager) async {
        if itemProducts.isEmpty {
            let itemData = JSONDataLoader.load(
                "itemShop",
                as: ItemShopData.self
            )
            itemProducts =
                itemData?.products.sorted { $0.sortOrder < $1.sortOrder } ?? []
        }

        if products.isEmpty {
            let data = JSONDataLoader.load("shop", as: ShopData.self)
            products =
                data?.products.sorted { $0.sortOrder < $1.sortOrder } ?? []
        }

        await store.loadProducts(
            productIds:
                products
                .filter { $0.purchaseType != .softCurrency }
                .map(\.productId)
        )
    }

    func priceTitle(for product: ShopProductData, store: StoreKitShopManager)
        -> String
    {
        guard product.purchaseType == .softCurrency,
            let priceCurrency = product.priceCurrency,
            let priceAmount = product.priceAmount
        else {
            if store.isLoadingProducts {
                return AppLocalizationService.text("shop.loading")
            }

            if store.isStoreKitUnavailable(product) {
                return AppLocalizationService.text("shop.unavailable")
            }

            return store.localizedPrice(for: product)
        }

        return "\(priceAmount) \(GameCurrency.title(for: priceCurrency))"
    }

    func cardState(
        for product: ShopProductData,
        gameStore: GameStore,
        store: StoreKitShopManager
    ) -> ShopStoreProductCardState {
        ShopStoreProductCardState(
            product: product,
            visual: productVisual(from: product.visual),
            title: product.localizedTitle,
            subtitle: product.localizedSubtitle ?? product.localizedTitle,
            price: priceTitle(for: product, store: store),
            soldOut: isPurchased(product, gameStore: gameStore, store: store),
            storeUnavailable: store.isStoreKitUnavailable(product),
            storeLoading: store.isLoadingProducts
        )
    }

    func itemCardState(
        for product: ItemShopProductData
    ) -> ShopItemProductCardState {
        ShopItemProductCardState(
            product: product,
            visual: productVisual(from: product.visual),
            title: product.localizedTitle,
            subtitle: product.localizedSubtitle
                ?? rewardTitle(for: product.rewards),
            priceCurrency: product.priceCurrency,
            priceAmount: product.priceAmount
        )
    }

    func isPurchased(
        _ product: ShopProductData,
        gameStore: GameStore,
        store: StoreKitShopManager
    ) -> Bool {
        if product.purchaseType == .nonConsumable,
            product.rewards.unlockEventPass == true
        {
            return gameStore.hasEventPass
        }

        return store.isPurchased(product)
    }

    func buyItem(_ product: ItemShopProductData, gameStore: GameStore) {
        let didBuy = gameStore.purchaseItem(product)
        showPurchaseMessage(
            didBuy
                ? AppLocalizationService.text("shop.itemPurchased")
                : AppLocalizationService.text("shop.notEnoughCurrency")
        )
    }

    func buy(
        _ product: ShopProductData,
        gameStore: GameStore,
        store: StoreKitShopManager
    ) async {
        if product.purchaseType == .softCurrency {
            let didBuy = gameStore.purchaseSoftCurrencyProduct(product)
            showPurchaseMessage(
                didBuy
                    ? AppLocalizationService.text("shop.itemPurchased")
                    : AppLocalizationService.text("shop.notEnoughCurrency")
            )
            return
        }

        let result = await store.purchase(product)

        switch result {
        case .purchased(let product, let shouldApplyRewards):
            if shouldApplyRewards {
                gameStore.applyShopRewards(from: product)
            } else {
                gameStore.syncShopEntitlements(
                    productIds: store.purchasedProductIds
                )
            }
            showPurchaseMessage(
                AppLocalizationService.text("shop.purchaseCompleted")
            )
        case .pending:
            showPurchaseMessage(
                AppLocalizationService.text("shop.purchasePending")
            )
        case .cancelled:
            purchaseMessage = nil
        case .failed(let message):
            handlePurchaseFailure(message)
        }
    }

    func restorePurchases(
        gameStore: GameStore,
        store: StoreKitShopManager
    ) async {
        await store.restorePurchases()
        gameStore.syncShopEntitlements(productIds: store.purchasedProductIds)
        showPurchaseMessage(
            AppLocalizationService.text("shop.restoreCompleted")
        )
    }

    private func handlePurchaseFailure(_ message: String) {
        guard !message.isEmpty else {
            purchaseMessage = nil
            return
        }

        showPurchaseMessage(message)
    }

    private func showPurchaseMessage(_ message: String) {
        purchaseMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            if purchaseMessage == message {
                purchaseMessage = nil
            }
        }
    }

    private func productVisual(from visual: String) -> ShopProductVisual {
        switch visual {
        case "crystals":
            .diamonds
        case "bits", "bit", "icon_bit":
            .bits
        case "coins":
            .emeralds
        case "tickets", "summon_ticket", "icon_summon_ticket":
            .tickets
        case "farm":
            .farm
        case "pass":
            .resource("pass")
        default:
            .resource(visual)
        }
    }

    private func rewardTitle(for rewards: ShopProductRewards) -> String {
        if let tickets = rewards.summonTickets {
            return "+\(tickets) \(GameCurrency.title(for: "summon_ticket"))"
        }

        if let crystals = rewards.crystals {
            return "+\(crystals) \(GameCurrency.title(for: "crystals"))"
        }

        if let coins = rewards.coins {
            return "+\(coins) \(GameCurrency.title(for: "coins"))"
        }

        if let bits = rewards.bits {
            return "+\(bits) \(GameCurrency.title(for: "bits"))"
        }

        return AppLocalizationService.text("shop.tab.item")
    }
}
