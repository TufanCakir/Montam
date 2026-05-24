//
//  PassConfig.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Foundation

struct PassIndex: Codable {
    let passes: [PassIndexEntry]
}

struct PassIndexEntry: Codable, Identifiable, Hashable {
    let id: String
    let file: String
}

struct PassConfig: Codable, Identifiable {
    let id: String
    let title: String
    let icon: String
    let backgroundImage: String?
    let infoTitle: String?
    let infoBody: String?
    let infoTasks: [String]?
    let currencyTitle: String
    let pointsPerTier: Int
    let tiers: [PassTier]
}

struct PassTier: Codable, Identifiable {
    let tier: Int
    let free: PassReward?
    let premium: PassReward?

    var id: Int { tier }
}

struct PassReward: Codable, Hashable {
    let title: String
    let type: GiftType
    let amount: Int?
    let characterId: String?
    let eggId: String?
    let skinId: String?
}

enum PassLoader {
    static func loadAll() -> [PassConfig] {
        do {
            let index: PassIndex = try JSONLoader.load("pass_index")
            return index.passes.compactMap { load($0.file) }
        } catch {
            if let legacy = load("pass_rewards") {
                return [legacy]
            }
            print("pass_index.json konnte nicht geladen werden:", error)
            return []
        }
    }

    static func load(_ file: String) -> PassConfig? {
        do {
            return try JSONLoader.load(file)
        } catch {
            print("\(file).json konnte nicht geladen werden:", error)
            return nil
        }
    }
}
