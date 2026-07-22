//
//  TradeOfferData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
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
