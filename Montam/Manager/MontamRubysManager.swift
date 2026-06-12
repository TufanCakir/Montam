//
//  MontamRubysManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamRubysManager: ObservableObject {
    static let shared = MontamRubysManager()

    @Published private(set) var montamRubys: Int = 0

    private let key = "montam_rubies"

    private init() {
        montamRubys = UserDefaults.standard.integer(forKey: key)
    }

    func add(_ amount: Int) {
        montamRubys += max(0, amount)
        save()
    }

    func spend(_ amount: Int) -> Bool {
        guard montamRubys >= amount else { return false }
        montamRubys -= amount
        save()
        return true
    }

    func reset() {
        montamRubys = 0
        save()
    }

    private func save() {
        UserDefaults.standard.set(montamRubys, forKey: key)
    }
}
