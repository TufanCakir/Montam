//
//  TradeOfferData.swift
//  Monster Transorfmieren
//

import Foundation

struct TradeOfferData: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let section: String
    let costCurrency: String
    let costAmount: Int
    let rewardCurrency: String
    let rewardAmount: Int
    let sortOrder: Int
}
