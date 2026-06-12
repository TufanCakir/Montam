//
//  PityManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

final class PityManager {

    static let shared = PityManager()
    private let prefix = "pity_"

    func resetAll() {
        let defaults = UserDefaults.standard
        defaults.dictionaryRepresentation().keys
            .filter { $0.starts(with: "pity_") }
            .forEach { defaults.removeObject(forKey: $0) }
    }

    func pulls(for bannerId: String) -> Int {
        UserDefaults.standard.integer(forKey: prefix + bannerId)
    }

    func addPull(for bannerId: String) {
        let current = pulls(for: bannerId)
        UserDefaults.standard.set(current + 1, forKey: prefix + bannerId)
    }

    func reset(for bannerId: String) {
        UserDefaults.standard.set(0, forKey: prefix + bannerId)
    }
}
