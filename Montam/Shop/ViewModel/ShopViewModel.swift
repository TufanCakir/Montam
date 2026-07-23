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
        products(in: selectedSection)
    }

    var selectedItemProducts: [ItemShopProductData] {
        itemProducts
    }

    func loadIfNeeded(store: StoreKitShopManager) async {
        if itemProducts.isEmpty {
            let itemData = JSONDataLoader.load("itemShop", as: ItemShopData.self)
            itemProducts =
                itemData?.products.sorted { $0.sortOrder < $1.sortOrder } ?? []
        }

        guard products.isEmpty else {
            return
        }

        let data = JSONDataLoader.load("shop", as: ShopData.self)
        let loadedProducts =
            data?.products.sorted { $0.sortOrder < $1.sortOrder } ?? []
        products = loadedProducts
        await store.loadProducts(
            productIds: loadedProducts
                .filter { $0.purchaseType != .softCurrency }
                .map(\.productId)
        )
    }

    func products(in section: ShopSection) -> [ShopProductData] {
        products.filter { $0.section == section.jsonKey }
    }

    func priceTitle(for product: ShopProductData, store: StoreKitShopManager)
        -> String
    {
        guard product.purchaseType == .softCurrency,
              let priceCurrency = product.priceCurrency,
              let priceAmount = product.priceAmount
        else {
            return store.localizedPrice(for: product)
        }

        return "\(priceAmount) \(GameCurrency.title(for: priceCurrency))"
    }
}
