//
//  ShopData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct ShopData: Codable {
    let products: [ShopProductData]
}

struct ShopProductData: Codable, Identifiable {
    let id: String
    let productId: String
    let section: String
    let purchaseType: ShopPurchaseType
    let title: String
    let subtitle: String?
    let visual: String
    let badge: String?
    let sortOrder: Int
    let rewards: ShopProductRewards
}

enum ShopPurchaseType: String, Codable {
    case consumable
    case nonConsumable
}

struct ShopProductRewards: Codable {
    let crystals: Int?
    let coins: Int?
    let bits: Int?
    let summonTickets: Int?
    let unlockEventPass: Bool?
}
