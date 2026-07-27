//
//  RuntimeOwnedSupporter.swift
//  Montam
//
//  Created by Tufan Cakir on 25.07.26.
//

import Foundation

struct RuntimeOwnedSupporter {
    let characterId: String
    let imageName: String
    let level: Int
    let isMonster: Bool
    let xOffset: Int?
    let yOffset: Int?
    let zOffset: Int?
    let scaleMultiplier: Double?
    let attackBonus: Double?
    let defenseBonus: Double?
    let healthBonus: Double?
    let hpRegenBonus: Double?
    let speedBonus: Double?
    let xpBonus: Double?
    let coinBonus: Double?
    let crystalBonus: Double?
    let bitBonus: Double?
    let ticketBonus: Double?
    let allCurrencyBonus: Double?
    let coinDropChanceBonus: Double?
    let crystalDropChanceBonus: Double?
    let bitDropChanceBonus: Double?
    let ticketDropChanceBonus: Double?

    init(
        characterId: String,
        imageName: String,
        level: Int,
        isMonster: Bool,
        xOffset: Int? = nil,
        yOffset: Int? = nil,
        zOffset: Int? = nil,
        scaleMultiplier: Double? = nil,
        attackBonus: Double? = nil,
        defenseBonus: Double? = nil,
        healthBonus: Double? = nil,
        hpRegenBonus: Double? = nil,
        speedBonus: Double? = nil,
        xpBonus: Double? = nil,
        coinBonus: Double? = nil,
        crystalBonus: Double? = nil,
        bitBonus: Double? = nil,
        ticketBonus: Double? = nil,
        allCurrencyBonus: Double? = nil,
        coinDropChanceBonus: Double? = nil,
        crystalDropChanceBonus: Double? = nil,
        bitDropChanceBonus: Double? = nil,
        ticketDropChanceBonus: Double? = nil
    ) {
        self.characterId = characterId
        self.imageName = imageName
        self.level = level
        self.isMonster = isMonster
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.zOffset = zOffset
        self.scaleMultiplier = scaleMultiplier
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.healthBonus = healthBonus
        self.hpRegenBonus = hpRegenBonus
        self.speedBonus = speedBonus
        self.xpBonus = xpBonus
        self.coinBonus = coinBonus
        self.crystalBonus = crystalBonus
        self.bitBonus = bitBonus
        self.ticketBonus = ticketBonus
        self.allCurrencyBonus = allCurrencyBonus
        self.coinDropChanceBonus = coinDropChanceBonus
        self.crystalDropChanceBonus = crystalDropChanceBonus
        self.bitDropChanceBonus = bitDropChanceBonus
        self.ticketDropChanceBonus = ticketDropChanceBonus
    }
}

struct SupporterBonusSummary {
    var attackBonus: Double = 0
    var defenseBonus: Double = 0
    var healthBonus: Double = 0
    var hpRegenBonus: Double = 0
    var speedBonus: Double = 0
    var xpBonus: Double = 0
    var coinBonus: Double = 0
    var crystalBonus: Double = 0
    var bitBonus: Double = 0
    var ticketBonus: Double = 0
    var allCurrencyBonus: Double = 0
    var coinDropChanceBonus: Double = 0
    var crystalDropChanceBonus: Double = 0
    var bitDropChanceBonus: Double = 0
    var ticketDropChanceBonus: Double = 0

    static func from(_ supporters: [RuntimeOwnedSupporter]) -> Self {
        supporters.reduce(Self()) { summary, supporter in
            var updated = summary
            updated.attackBonus += supporter.attackBonus ?? 0
            updated.defenseBonus += supporter.defenseBonus ?? 0
            updated.healthBonus += supporter.healthBonus ?? 0
            updated.hpRegenBonus += supporter.hpRegenBonus ?? 0
            updated.speedBonus += supporter.speedBonus ?? 0
            updated.xpBonus += supporter.xpBonus ?? 0
            updated.coinBonus += supporter.coinBonus ?? 0
            updated.crystalBonus += supporter.crystalBonus ?? 0
            updated.bitBonus += supporter.bitBonus ?? 0
            updated.ticketBonus += supporter.ticketBonus ?? 0
            updated.allCurrencyBonus += supporter.allCurrencyBonus ?? 0
            updated.coinDropChanceBonus += supporter.coinDropChanceBonus ?? 0
            updated.crystalDropChanceBonus += supporter.crystalDropChanceBonus ?? 0
            updated.bitDropChanceBonus += supporter.bitDropChanceBonus ?? 0
            updated.ticketDropChanceBonus += supporter.ticketDropChanceBonus ?? 0
            return updated
        }
    }

    var displayLines: [String] {
        [
            line("ATK", attackBonus),
            line("DEF", defenseBonus),
            line("Leben", healthBonus),
            line("HP-Regeneration", hpRegenBonus),
            line("Tempo", speedBonus),
            line("EXP", xpBonus),
            line("Alle Waehrungen", allCurrencyBonus),
            line("Coins", coinBonus),
            line("Kristalle", crystalBonus),
            line("Bits", bitBonus),
            line("Tickets", ticketBonus),
            line("Coin-Drop", coinDropChanceBonus),
            line("Kristall-Drop", crystalDropChanceBonus),
            line("Bit-Drop", bitDropChanceBonus),
            line("Ticket-Drop", ticketDropChanceBonus),
        ].compactMap { $0 }
    }

    private func line(_ title: String, _ value: Double) -> String? {
        guard value > 0 else { return nil }
        let percent = Int((value * 100).rounded())
        return "+\(percent)% \(title)"
    }
}
