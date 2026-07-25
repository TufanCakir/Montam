//
//  BattleRewardData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct BattleRewardData: Codable {
    let battleCoins: Int
    let battleCrystals: Int
    let battleBits: Int?
    let coinDropChance: Double?
    let crystalDropChance: Double?
    let bitDropChance: Double?
    let battleeventExp: Int
}
