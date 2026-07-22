//
//  ShopViewModel.swift
//  Monster Transorfmieren
//

import Observation

@MainActor
@Observable
final class ShopViewModel {
    var selectedSection = ShopSection.premiumCurrency
    var products: [ShopProductData] = []
    var purchaseMessage: String?

    var selectedProducts: [ShopProductData] {
        products(in: selectedSection)
    }

    func loadIfNeeded(store: StoreKitShopManager) async {
        guard products.isEmpty else {
            return
        }

        let data = JSONDataLoader.load("shop", as: ShopData.self)
        let loadedProducts = data?.products.sorted { $0.sortOrder < $1.sortOrder } ?? []
        products = loadedProducts
        await store.loadProducts(productIds: loadedProducts.map(\.productId))
    }

    func products(in section: ShopSection) -> [ShopProductData] {
        products.filter { $0.section == section.jsonKey }
    }
}
