//
//  MontamShardsManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamShardsManager: ObservableObject {
    static let shared = MontamShardsManager()

    @Published private(set) var montamShards: Int = 0

    private let key = "montam_shards"

    private init() {
        montamShards = UserDefaults.standard.integer(forKey: key)
    }

    func add(_ amount: Int) {
        montamShards += max(0, amount)
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard montamShards >= amount else { return false }
        montamShards -= amount
        save()
        return true
    }

    func reset() {
        montamShards = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(montamShards, forKey: key)
    }
}
