//
//  RewardData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct RewardData: Codable, Identifiable {
    let id: String
    let resourceId: String
    let amount: Int
}
