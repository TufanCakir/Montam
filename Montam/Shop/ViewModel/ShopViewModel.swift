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

            #if DEBUG
                debugPrintLoadedShopProducts(products)
            #endif
        }

        await store.loadProducts(
            productIds:
                products
                .filter { $0.purchaseType != .softCurrency }
                .map(\.productId)
        )
    }

    func products(in section: ShopSection) -> [ShopProductData] {
        products.filter { $0.section == section.jsonKey }
    }

    #if DEBUG
        private func debugPrintLoadedShopProducts(_ products: [ShopProductData])
        {
            print("========== SHOP JSON DEBUG ==========")
            print("Shop product count: \(products.count)")
            for product in products {
                print(
                    [
                        "shopId=\(product.id)",
                        "productId=\(product.productId)",
                        "type=\(product.purchaseType.rawValue)",
                        "section=\(product.section)",
                        "title=\(product.title)",
                    ].joined(separator: " | ")
                )
            }
            print("=====================================")
        }
    #endif

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
