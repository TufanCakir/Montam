//
//  ShopManager.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import StoreKit

@MainActor
class ShopManager {

    private static let purchaseCountPrefix = "shop_purchase_count_"
    private static let legacyBoughtPrefix = "shop_bought_"

    func buildStoreProducts(
        shopItems: [ShopItem]
    ) -> [StoreProduct] {

        var storeProducts: [StoreProduct] = []

        let availableItems = shopItems.filter(Self.canPurchase)

        for item in availableItems {

            if let id = item.storeProductId,
                let product = StoreKitService.shared.product(for: id)
            {

                storeProducts.append(
                    StoreProduct(product: product, shopItem: item)
                )

            } else {
                storeProducts.append(
                    StoreProduct(product: nil, shopItem: item)
                )
            }
        }

        return storeProducts.sorted {
            $0.shopItem.rewardAmount < $1.shopItem.rewardAmount
        }
    }

    static func canPurchase(_ item: ShopItem) -> Bool {
        remainingPurchases(for: item) != 0
    }

    static func purchaseCount(for item: ShopItem) -> Int {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "\(legacyBoughtPrefix)\(item.id)") {
            return max(1, defaults.integer(forKey: countKey(for: item.id)))
        }
        return defaults.integer(forKey: countKey(for: item.id))
    }

    static func remainingPurchases(for item: ShopItem) -> Int? {
        guard let limit = effectiveLimit(for: item) else { return nil }
        return max(0, limit - purchaseCount(for: item))
    }

    static func recordPurchase(_ item: ShopItem) {
        let count = purchaseCount(for: item) + 1
        UserDefaults.standard.set(count, forKey: countKey(for: item.id))

        if item.oneTimePurchase == true {
            UserDefaults.standard.set(
                true,
                forKey: "\(legacyBoughtPrefix)\(item.id)"
            )
        }
    }

    static func effectiveLimit(for item: ShopItem) -> Int? {
        if item.oneTimePurchase == true {
            return min(item.purchaseLimit ?? 1, 1)
        }
        return item.purchaseLimit
    }

    private static func countKey(for id: String) -> String {
        "\(purchaseCountPrefix)\(id)"
    }
}
