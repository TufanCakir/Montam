//
//  MontamMedalManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class MontamMedalManager: ObservableObject {
    static let shared = MontamMedalManager()

    @Published private(set) var medals: [String: Int] = [:]

    private let key = "montam_medals"

    private init() {
        guard let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode(
                [String: Int].self,
                from: data
            )
        else { return }

        medals = decoded
    }

    func amount(for id: String) -> Int {
        medals[id, default: 0]
    }

    func add(_ amount: Int, medalId: String) {
        medals[medalId, default: 0] += max(0, amount)
        save()
    }

    func spend(_ amount: Int, medalId: String) -> Bool {
        guard medals[medalId, default: 0] >= amount else { return false }
        medals[medalId, default: 0] -= amount
        save()
        return true
    }

    func reset() {
        medals.removeAll()
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(medals) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
