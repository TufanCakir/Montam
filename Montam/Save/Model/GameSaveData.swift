//
//  GameSaveData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation
import SwiftData

@Model
final class GameSaveData {
    var createdAt: Date
    var didCompleteOnboarding: Bool
    var playerLevel: Int
    var playerPower: Int
    var playerXP: Int
    var playerMaxXP: Int
    var currentStage: Int = 1
    var bits: Int
    var coins: Int
    var crystals: Int
    var summonTickets: Int
    var hasEventPass: Bool
    var ownedStoreProductIds: [String] = []
    var montamPassPoints: Int
    var lastDailyClaimDate: Date?
    var dailyLoginDay: Int
    var claimedGiftIds: [String]
    var claimedMissionRewardIds: [String] = []
    var claimedBattlePassRewardIds: [String] = []

    init(
        createdAt: Date = .now,
        didCompleteOnboarding: Bool = false,
        playerLevel: Int = 1,
        playerPower: Int = 0,
        playerXP: Int = 0,
        playerMaxXP: Int = 100,
        currentStage: Int = 1,
        bits: Int = 0,
        coins: Int = 0,
        crystals: Int = 0,
        summonTickets: Int = 0,
        hasEventPass: Bool = false,
        ownedStoreProductIds: [String] = [],
        montamPassPoints: Int = 0,
        lastDailyClaimDate: Date? = nil,
        dailyLoginDay: Int = 0,
        claimedGiftIds: [String] = [],
        claimedMissionRewardIds: [String] = [],
        claimedBattlePassRewardIds: [String] = []
    ) {
        self.createdAt = createdAt
        self.didCompleteOnboarding = didCompleteOnboarding
        self.playerLevel = playerLevel
        self.playerPower = playerPower
        self.playerXP = playerXP
        self.playerMaxXP = playerMaxXP
        self.currentStage = currentStage
        self.bits = bits
        self.coins = coins
        self.crystals = crystals
        self.summonTickets = summonTickets
        self.hasEventPass = hasEventPass
        self.ownedStoreProductIds = ownedStoreProductIds
        self.montamPassPoints = montamPassPoints
        self.lastDailyClaimDate = lastDailyClaimDate
        self.dailyLoginDay = dailyLoginDay
        self.claimedGiftIds = claimedGiftIds
        self.claimedMissionRewardIds = claimedMissionRewardIds
        self.claimedBattlePassRewardIds = claimedBattlePassRewardIds
    }
}

extension GameSaveData {
    func amount(for currency: String) -> Int {
        return switch GameCurrency.normalized(currency) {
        case "coins":
            coins
        case "crystals":
            crystals
        case "bits":
            bits
        case "summon_ticket":
            summonTickets
        default:
            0
        }
    }

    func canSpend(_ currency: String, amount: Int) -> Bool {
        guard amount >= 0 else {
            return false
        }

        switch GameCurrency.normalized(currency) {
        case "coins", "crystals", "bits", "summon_ticket":
            return self.amount(for: currency) >= amount
        default:
            return false
        }
    }

    @discardableResult
    func spend(_ currency: String, amount: Int) -> Bool {
        guard canSpend(currency, amount: amount) else {
            return false
        }

        return changeCurrency(currency, by: -amount)
    }

    @discardableResult
    func changeCurrency(_ currency: String, by amount: Int) -> Bool {
        switch GameCurrency.normalized(currency) {
        case "coins":
            coins += amount
        case "crystals":
            crystals += amount
        case "bits":
            bits += amount
        case "summon_ticket":
            summonTickets += amount
        default:
            return false
        }

        return true
    }

    @discardableResult
    func markStoreProductOwned(_ productId: String) -> Bool {
        guard !ownedStoreProductIds.contains(productId) else {
            return false
        }

        ownedStoreProductIds.append(productId)
        return true
    }
}

@Model
final class OwnedMonsterData {
    @Attribute(.unique) var monsterId: String
    var level: Int
    var xp: Int
    var isSelected: Bool
    var equippedImageName: String?

    init(
        monsterId: String,
        level: Int = 1,
        xp: Int = 0,
        isSelected: Bool = false,
        equippedImageName: String? = nil
    ) {
        self.monsterId = monsterId
        self.level = level
        self.xp = xp
        self.isSelected = isSelected
        self.equippedImageName = equippedImageName
    }
}

@Model
final class OwnedTamerData {
    @Attribute(.unique) var tamerId: String
    var level: Int
    var xp: Int
    var isSelected: Bool

    init(tamerId: String, level: Int = 1, xp: Int = 0, isSelected: Bool = false)
    {
        self.tamerId = tamerId
        self.level = level
        self.xp = xp
        self.isSelected = isSelected
    }
}
