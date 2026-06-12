//
//  MontamLiquidManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamLiquidManager: ObservableObject {
    static let shared = MontamLiquidManager()

    @Published private(set) var montamLiquid: Int = 0

    private let key = "montam_liquid"

    private init() {
        montamLiquid = UserDefaults.standard.integer(forKey: key)
    }

    func add(_ amount: Int) {
        montamLiquid += max(0, amount)
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard montamLiquid >= amount else { return false }
        montamLiquid -= amount
        save()
        return true
    }

    func reset() {
        montamLiquid = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(montamLiquid, forKey: key)
    }
}
