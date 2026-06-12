//
//  MontamContainersManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamContainersManager: ObservableObject {
    static let shared = MontamContainersManager()

    @Published private(set) var tokens: Int = 0

    private let key = "montam_event_tokens"

    private init() {
        tokens = UserDefaults.standard.integer(forKey: key)
    }

    func add(_ amount: Int) {
        tokens += max(0, amount)
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard tokens >= amount else { return false }
        tokens -= amount
        save()
        return true
    }

    func reset() {
        tokens = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(tokens, forKey: key)
    }
}
