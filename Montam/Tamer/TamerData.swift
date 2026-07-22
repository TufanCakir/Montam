//
//  TamerData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct TamerData: Codable {
    let id: String
    let tamerName: String
    let name: String
    let rarity: String?
    let supportAttackBonus: Double?
    let supportDefenseBonus: Double?
    let supportHealthBonus: Double?
    let tamerGrowthRate: Double?
    let yOffset: Int
    let xOffset: Int
    let zOffset: Int
}
