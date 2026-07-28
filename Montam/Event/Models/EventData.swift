//
//  EventData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct EventData: Decodable, Identifiable {
    let id: String
    let category: String
    let eventBackground: String
    let title: String
    let description: String
    let titleKey: String?
    let descriptionKey: String?
    let enemyName: String
    let maxPlays: Int?
    let resetIntervalHours: Int?
    let battleXPReward: Int?
    let rewards: [EventRewardItem]
    let progress: String?
    let adProgress: String?
    let locked: Bool?

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedDescription: String {
        if let descriptionKey {
            return AppLocalizationService.text(descriptionKey)
        }

        return description
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case category
        case eventBackground
        case title
        case description
        case titleKey
        case descriptionKey
        case enemyName
        case rewardCurrency
        case rewardAmount
        case maxPlays
        case resetIntervalHours
        case battleXPReward
        case rewards
        case progress
        case adProgress
        case locked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        category = try container.decode(String.self, forKey: .category)
        eventBackground = try container.decode(
            String.self,
            forKey: .eventBackground
        )
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        titleKey = try container.decodeIfPresent(String.self, forKey: .titleKey)
        descriptionKey = try container.decodeIfPresent(
            String.self,
            forKey: .descriptionKey
        )
        enemyName = try container.decode(String.self, forKey: .enemyName)
        maxPlays = try container.decodeIfPresent(Int.self, forKey: .maxPlays)
        resetIntervalHours = try container.decodeIfPresent(
            Int.self,
            forKey: .resetIntervalHours
        )
        battleXPReward = try container.decodeIfPresent(
            Int.self,
            forKey: .battleXPReward
        )
        progress = try container.decodeIfPresent(String.self, forKey: .progress)
        adProgress = try container.decodeIfPresent(
            String.self,
            forKey: .adProgress
        )
        locked = try container.decodeIfPresent(Bool.self, forKey: .locked)

        if let rewards = try container.decodeIfPresent(
            [EventRewardItem].self,
            forKey: .rewards
        ) {
            self.rewards = rewards
        } else if let rewardCurrency = try container.decodeIfPresent(
            String.self,
            forKey: .rewardCurrency
        ) {
            let amount =
                try container.decodeIfPresent(Int.self, forKey: .rewardAmount)
                ?? 1
            rewards = [
                EventRewardItem(currency: rewardCurrency, amount: amount)
            ]
        } else {
            rewards = []
        }
    }
}

struct EventRewardItem: Decodable, Identifiable {
    var id: String { currency }
    let currency: String
    let amount: Int
}
