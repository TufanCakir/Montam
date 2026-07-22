//
//  SummonCostData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct SummonCostData: Codable {
    let amountPool: Int
    let singleTicketalCost: Int
    let multiTicketalCost: Int
    let singleCrystalCost: Int
    let multiCrystalCost: Int
    let maxSummons: Int
}

