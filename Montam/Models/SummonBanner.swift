//
//  SummonBanner.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct SummonBanner: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    let currency: String
    let bannerImage: String
    let summons: [SummonOption]
    let maxSummons: Int
    let pool: [SummonPoolEntry]

    let pity: PitySystem?
    let stepUp: StepUpSystem?
}

struct SummonOption: Codable, Identifiable {
    var id: Int { amount }
    let amount: Int
    let cost: Int
}

struct SummonPoolEntry: Codable, Identifiable {

    var id: String { characterId }

    let characterId: String
    let rateUp: Bool
}
