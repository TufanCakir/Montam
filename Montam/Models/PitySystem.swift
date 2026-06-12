//
//  PitySystem.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct PitySystem: Codable {
    let enabled: Bool
    let requiredPulls: Int
    let guaranteedPool: [PityEntry]
}

struct PityEntry: Codable {
    let characterId: String
}
