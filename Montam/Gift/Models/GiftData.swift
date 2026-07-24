//
//  GiftData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct GiftData: Codable, Identifiable {
    let id: String
    let title: String
    let message: String?
    let rewards: [RewardData]
    let expiresAt: String?

    init(
        id: String = "starter_gift",
        title: String = "Geschenk",
        message: String? = nil,
        rewards: [RewardData],
        expiresAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.rewards = rewards
        self.expiresAt = expiresAt
    }
}
