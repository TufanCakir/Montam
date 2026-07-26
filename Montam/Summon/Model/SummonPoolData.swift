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
}

struct SupporterData: Codable {
    let bannerId: String
    let characterId: String
    let weight: Int?
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

extension SupporterData {
    static func loadAll() -> [SupporterData] {
        let supportMonsters =
            JSONDataLoader.load("supportMonster", as: [SupporterData].self)
            ?? []
        let supportMegaMonsters =
            JSONDataLoader.load("supportMegaMonster", as: [SupporterData].self)
            ?? []
        let supportTamers =
            JSONDataLoader.load("supportTamer", as: [SupporterData].self) ?? []

        return supportMonsters + supportMegaMonsters + supportTamers
    }
}
