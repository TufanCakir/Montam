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
    let titleKey: String?
    let messageKey: String?
    let rewards: [RewardData]
    let expiresAt: String?

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedMessage: String? {
        if let messageKey {
            return AppLocalizationService.text(messageKey)
        }

        return message
    }

    init(
        id: String = "starter_gift",
        title: String = "Geschenk",
        message: String? = nil,
        titleKey: String? = nil,
        messageKey: String? = nil,
        rewards: [RewardData],
        expiresAt: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.titleKey = titleKey
        self.messageKey = messageKey
        self.rewards = rewards
        self.expiresAt = expiresAt
    }
}
