//
//  EventVictoryResult.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct EventVictoryResult: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let montamCoins: Int
    let montamRubys: Int
    let montamContainers: Int
    let montamLiquid: Int
    let eggRewards: [EggReward]
    let medalId: String?
    let medalTitle: String?
    let medalIcon: String?
    let medals: Int
}
