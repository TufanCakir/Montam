//
//  ShopViewModel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Observation

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
                return "Lade..."
            }

            if store.isStoreKitUnavailable(product) {
                return "Bald verfügbar"
            }

            return store.localizedPrice(for: product)
        }

        return "\(priceAmount) \(GameCurrency.title(for: priceCurrency))"
    }
}
