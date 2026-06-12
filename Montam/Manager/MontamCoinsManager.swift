//
//  MontamCoinsManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamCoinsManager: ObservableObject {

    static let shared = MontamCoinsManager()

    @Published private(set) var montamCoins: Int = 0

    private let key = "montam_coins"

    private init() {
        load()
    }

    func reset() {
        montamCoins = 0
        save()
    }

    // MARK: Add

    func add(_ amount: Int) {

        guard amount > 0 else { return }

        montamCoins += amount

        save()
    }

    // MARK: Spend

    @discardableResult
    func spend(_ amount: Int) -> Bool {

        guard montamCoins >= amount else { return false }

        montamCoins -= amount

        save()

        return true
    }

    // MARK: Save

    private func save() {

        UserDefaults.standard.set(
            montamCoins,
            forKey: key
        )
    }

    // MARK: Load

    private func load() {

        montamCoins =
            UserDefaults.standard.integer(
                forKey: key
            )
    }
}
