//
//  EvolutionData.swift
//  Monster Transorfmieren
//

import Foundation

struct EvolutionData: Codable, Identifiable {
    let id: String
    let sourceMonsterId: String
    let targetMonsterId: String
    let targetImageName: String
    let displayName: String
    let requiredLevel: Int
    let coinCost: Int?
    let crystalCost: Int?
}
