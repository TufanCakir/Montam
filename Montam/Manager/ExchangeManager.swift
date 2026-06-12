//
//  ExchangeManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class ExchangeManager: ObservableObject {

    static let shared = ExchangeManager()

    @Published var offers: [ExchangeOffer] = []
    @Published private(set) var purchasedNormal: [String: Int] = [:]

    private let purchaseKeyNormal = "exchange_purchases_normal"

    private init() {
        loadOffers()
        loadPurchases()
    }

    // MARK: - Remaining
    func remaining(_ offer: ExchangeOffer) -> Int {

        let bought = purchasedNormal[offer.id] ?? 0

        return max(0, offer.purchaseLimit - bought)
    }

    // MARK: - Reset
    func reset() {
        purchasedNormal = [:]
        save()
    }

    // MARK: - Load JSON
    private func loadOffers() {
        do {
            offers = try JSONLoader.load("exchange")
        } catch {
            print("❌ Failed to load exchange:", error)
        }
    }

    // MARK: - Buy
    func buy(offer: ExchangeOffer) -> Bool {

        let bought = purchasedNormal[offer.id] ?? 0

        guard bought < offer.purchaseLimit else { return false }

        guard let cost = offer.coinCost,
            let reward = offer.gemReward
        else { return false }

        let success = MontamCoinsManager.shared.spend(cost)

        if success {
            MontamSaphirsManager.shared.add(reward)
            purchasedNormal[offer.id] = bought + 1
        }

        guard success else { return false }

        save()
        return true
    }

    // MARK: - Persistence
    private func save() {
        UserDefaults.standard.set(purchasedNormal, forKey: purchaseKeyNormal)
    }

    private func loadPurchases() {
        purchasedNormal =
            UserDefaults.standard.dictionary(forKey: purchaseKeyNormal)
            as? [String: Int] ?? [:]
    }
}
