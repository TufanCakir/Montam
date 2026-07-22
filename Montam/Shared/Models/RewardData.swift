//
//  RewardData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import Foundation

struct RewardData: Codable, Identifiable {
    let id: String
    let resourceId: String
    let amount: Int
}
