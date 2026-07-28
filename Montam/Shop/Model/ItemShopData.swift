//
//  ItemShopData.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import Foundation

struct ItemShopData: Codable {
    let products: [ItemShopProductData]
}

struct ItemShopProductData: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let titleKey: String?
    let subtitleKey: String?
    let visual: String
    let badge: String?
    let priceCurrency: String
    let priceAmount: Int
    let sortOrder: Int
    let rewards: ShopProductRewards

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedSubtitle: String? {
        if let subtitleKey {
            return AppLocalizationService.text(subtitleKey)
        }

        return subtitle
    }
}
