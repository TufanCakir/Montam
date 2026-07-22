//
//  GameCurrency.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

enum GameCurrency {
    static func normalized(_ currency: String) -> String {
        switch currency {
        case "coin", "coins": "coins"
        case "crystal", "crystals": "crystals"
        case "ticket", "tickets", "summon_ticket": "summon_ticket"
        case "bit", "bits": "bits"
        default: currency
        }
    }

    static func title(for currency: String) -> String {
        switch normalized(currency) {
        case "coins": "Coins"
        case "crystals": "Kristalle"
        case "summon_ticket": "Tickets"
        case "bits": "Bits"
        default: currency
        }
    }

    static func iconId(for currency: String) -> String {
        switch normalized(currency) {
        case "coins": "coin"
        case "crystals": "crystal"
        case "summon_ticket": "summon_ticket"
        case "bits": "bit"
        default: currency
        }
    }
}
