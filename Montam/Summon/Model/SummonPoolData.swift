//
//  SummonPoolData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct SummonPoolData: Codable {
    let bannerId: String
    let characterId: String
    let weight: Int
    let xOffset: Int?
    let yOffset: Int?
    let zOffset: Int?
    let scaleMultiplier: Double?
    let attackBonus: Double?
    let defenseBonus: Double?
    let healthBonus: Double?
    let xpBonus: Double?
    let coinBonus: Double?
    let crystalBonus: Double?
    let bitBonus: Double?
    let ticketBonus: Double?
}
