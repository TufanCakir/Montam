//
//  EventData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct EventData: Codable, Identifiable {
    let id: String
    let category: String
    let eventBackground: String
    let title: String
    let description: String
    let enemyName: String
    let rewardCurrency: String
    let durationDays: Int
    let progress: String?
    let adProgress: String?
    let timer: String?
    let locked: Bool?
}
