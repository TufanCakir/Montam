//
//  PlayerProgressManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class PlayerProgressManager: ObservableObject {

    static let shared = PlayerProgressManager()

    @Published private(set) var level: Int = 1
    @Published private(set) var exp: Int = 0

    private let levelKey = "player_level"
    private let expKey = "player_exp"

    // ⭐ EXP Curve Settings
    private let expGrowth = 1.12
    private let baseEXP = 100.0

    private init() {
        load()
    }

    func reset() {
        level = 1
        exp = 0
        save()
    }

    // MARK: EXP System

    func addEXP(_ amount: Int) {

        exp += amount

        while exp >= requiredEXP {

            exp -= requiredEXP
            level += 1
        }

        save()
    }

    var requiredEXP: Int {

        Int(
            baseEXP * pow(expGrowth, Double(level - 1))
        )
    }

    // MARK: Save

    private func save() {

        let d = UserDefaults.standard

        d.set(level, forKey: levelKey)
        d.set(exp, forKey: expKey)
    }

    private func load() {

        let d = UserDefaults.standard

        level = max(1, d.integer(forKey: levelKey))
        exp = d.integer(forKey: expKey)
    }
}
