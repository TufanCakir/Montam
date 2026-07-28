//
//  GameCurrency.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum GameCurrency {
    private struct CurrencyInfo {
        let titleKey: String
        let iconId: String
    }

    private static let infoByCurrency: [String: CurrencyInfo] = [
        "coins": CurrencyInfo(titleKey: "currency.coins", iconId: "coin"),
        "crystals": CurrencyInfo(
            titleKey: "currency.crystals",
            iconId: "crystal"
        ),
        "summon_ticket": CurrencyInfo(
            titleKey: "currency.tickets",
            iconId: "summon_ticket"
        ),
        "bits": CurrencyInfo(titleKey: "currency.bits", iconId: "bit"),
        "exp": CurrencyInfo(titleKey: "currency.exp", iconId: "exp"),
    ]

    private static let aliases: [String: String] = [
        "coin": "coins",
        "coins": "coins",
        "crystal": "crystals",
        "crystals": "crystals",
        "ticket": "summon_ticket",
        "tickets": "summon_ticket",
        "summon_ticket": "summon_ticket",
        "bit": "bits",
        "bits": "bits",
        "exp": "exp",
        "xp": "exp",
    ]

    static func normalized(_ currency: String) -> String {
        let key = currency.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return aliases[key] ?? key
    }

    static func title(for currency: String) -> String {
        guard let info = infoByCurrency[normalized(currency)] else {
            return currency
        }

        return AppLocalizationService.text(info.titleKey)
    }

    static func iconId(for currency: String) -> String {
        infoByCurrency[normalized(currency)]?.iconId ?? currency
    }

    static func apply(_ reward: RewardData, to save: GameSaveData) {
        save.changeCurrency(reward.resourceId, by: reward.amount)
    }
}
