//
//  EggInventoryManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class EggInventoryManager: ObservableObject {
    static let shared = EggInventoryManager()

    @Published private(set) var eggs: [String: Int] = [:]

    private let key = "montam_egg_inventory"

    private init() {
        load()
    }

    func count(for eggId: String) -> Int {
        eggs[eggId, default: 0]
    }

    func add(_ amount: Int, eggId: String) {
        guard amount > 0 else { return }
        eggs[eggId, default: 0] += amount
        save()
    }

    @discardableResult
    func consume(_ amount: Int = 1, eggId: String) -> Bool {
        guard count(for: eggId) >= amount else { return false }
        eggs[eggId, default: 0] -= amount

        if eggs[eggId, default: 0] <= 0 {
            eggs.removeValue(forKey: eggId)
        }

        save()
        return true
    }

    func reset() {
        eggs = [:]
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(eggs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(
                [String: Int].self,
                from: data
            )
        else {
            eggs = [:]
            return
        }

        eggs = decoded
    }
}
