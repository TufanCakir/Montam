//
//  SummonData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct SummonData: Codable {
    let id: String
    let title: String
    let category: String
    let currency: String
    let singleCost: Int
    let multiCost: Int
    let bannerImage: String
    let rates: [SummonRateData]?
}

struct SummonRateData: Codable, Identifiable {
    let rarity: String
    let title: String
    let weight: Int

    var id: String { rarity }
}
