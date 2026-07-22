//
//  GiftData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct GiftData: Codable, Identifiable {
    let id: String
    let title: String
    let message: String?
    let coins: Int
    let crystals: Int
    let bits: Int?
    let summonTickets: Int?
    let expiresAt: String?

    init(
        id: String = "starter_gift",
        title: String = "Geschenk",
        message: String? = nil,
        coins: Int,
        crystals: Int,
        bits: Int? = nil,
        summonTickets: Int? = nil,
        expiresAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.coins = coins
        self.crystals = crystals
        self.bits = bits
        self.summonTickets = summonTickets
        self.expiresAt = expiresAt
    }
}
