//
//  DailyReward.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct DailyReward: Codable, Identifiable {
    let day: Int

    let montamCoins: Int?
    let montamSaphirs: Int?
    let montamRubys: Int?
    let montamLiquid: Int?
    let montamShards: Int?
    let montamContainers: Int?
    let exp: Int?

    var id: Int { day }
}

enum DailyRewardLoader {

    static func load() -> [DailyReward] {
        do {
            let rewards: [DailyReward] = try JSONLoader.load("daily_rewards")
            return rewards.sorted { $0.day < $1.day }
        } catch {
            print("daily_rewards.json konnte nicht geladen werden:", error)
            return []
        }
    }
}
