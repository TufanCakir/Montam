//
//  MontamSaphirsManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamSaphirsManager: ObservableObject {

    static let shared = MontamSaphirsManager()

    @Published private(set) var montamSaphirs: Int = 0

    private let key = "montam_gems"

    private init() {
        load()
    }

    func reset() {
        montamSaphirs = 0
        save()
    }

    // MARK: Add

    func add(_ amount: Int) {

        guard amount > 0 else { return }

        montamSaphirs += amount

        save()
    }

    // MARK: Spend

    @discardableResult
    func spend(_ amount: Int) -> Bool {

        guard montamSaphirs >= amount else {
            return false
        }

        montamSaphirs -= amount

        save()

        return true
    }

    private func save() {

        UserDefaults.standard.set(
            montamSaphirs,
            forKey: key
        )
    }

    private func load() {

        montamSaphirs =
            UserDefaults.standard.integer(
                forKey: key
            )
    }
}
