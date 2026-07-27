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

struct SupporterData: Decodable {
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
    let hpRegenBonus: Double?
    let speedBonus: Double?
    let xpBonus: Double?
    let coinBonus: Double?
    let crystalBonus: Double?
    let bitBonus: Double?
    let ticketBonus: Double?
    let allCurrencyBonus: Double?
    let coinDropChanceBonus: Double?
    let crystalDropChanceBonus: Double?
    let bitDropChanceBonus: Double?
    let ticketDropChanceBonus: Double?

    enum CodingKeys: String, CodingKey {
        case bannerId
        case characterId
        case weight
        case xOffset
        case yOffset
        case zOffset
        case scaleMultiplier
        case attackBonus
        case defenseBonus
        case healthBonus
        case hpRegenBonus
        case regenBonus
        case speedBonus
        case xpBonus
        case coinBonus
        case crystalBonus
        case bitBonus
        case ticketBonus
        case allCurrencyBonus
        case currencyBonus
        case coinDropChanceBonus
        case crystalDropChanceBonus
        case bitDropChanceBonus
        case ticketDropChanceBonus
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bannerId = try container.decode(String.self, forKey: .bannerId)
        characterId = try container.decode(String.self, forKey: .characterId)
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        xOffset = try container.decodeIfPresent(Int.self, forKey: .xOffset)
        yOffset = try container.decodeIfPresent(Int.self, forKey: .yOffset)
        zOffset = try container.decodeIfPresent(Int.self, forKey: .zOffset)
        scaleMultiplier = try container.decodeIfPresent(
            Double.self,
            forKey: .scaleMultiplier
        )
        attackBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .attackBonus
        )
        defenseBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .defenseBonus
        )
        healthBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .healthBonus
        )
        hpRegenBonus =
            try container.decodeIfPresent(Double.self, forKey: .hpRegenBonus)
            ?? container.decodeIfPresent(Double.self, forKey: .regenBonus)
        speedBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .speedBonus
        )
        xpBonus = try container.decodeIfPresent(Double.self, forKey: .xpBonus)
        coinBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .coinBonus
        )
        crystalBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .crystalBonus
        )
        bitBonus = try container.decodeIfPresent(Double.self, forKey: .bitBonus)
        ticketBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .ticketBonus
        )
        allCurrencyBonus =
            try container.decodeIfPresent(
                Double.self,
                forKey: .allCurrencyBonus
            )
            ?? container.decodeIfPresent(Double.self, forKey: .currencyBonus)
        coinDropChanceBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .coinDropChanceBonus
        )
        crystalDropChanceBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .crystalDropChanceBonus
        )
        bitDropChanceBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .bitDropChanceBonus
        )
        ticketDropChanceBonus = try container.decodeIfPresent(
            Double.self,
            forKey: .ticketDropChanceBonus
        )
    }
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
