//
//  ExchangeOffer.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct ExchangeOffer: Codable, Identifiable {

    let id: String
    let title: String

    // 🟡 NORMAL
    let coinCost: Int?
    let gemReward: Int?

    let purchaseLimit: Int
}
