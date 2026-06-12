//
//  OwnedCharacter.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation
import SwiftUI

final class OwnedCharacter: Codable, Identifiable {

    let id: String
    let baseId: String
    let base: Character

    var level: Int = 1
    var exp: Int = 0
    var stars: Int = 1

    static let maxStars = 14

    var starMultiplier: Double {
        1.0 + Double(max(0, stars - 1)) * 0.08 + Double(max(0, stars - 7))
            * 0.05
    }

    var starColor: Color {
        isAwakened ? MontamPalette.blue : base.rarity.color
    }

    var starGradient: LinearGradient {
        LinearGradient(
            colors: isAwakened
                ? [MontamPalette.blue, .white.opacity(0.72)]
                : [base.rarity.color, MontamPalette.gold],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var isMaxStar: Bool {
        stars >= Self.maxStars
    }

    var isAwakened: Bool {
        stars > 7
    }

    // MARK: - EXP SYSTEM

    var requiredEXP: Int {
        Int(100 * pow(1.12, Double(level - 1)))
    }

    var totalHP: Int {
        Int(Double(base.stats.hp) * starMultiplier)
    }

    var totalAttack: Int {
        Int(Double(base.stats.attack) * starMultiplier)
    }

    var totalEnergyPower: Int {
        Int(Double(base.stats.energyPower) * starMultiplier)
    }

    // MARK: - INIT

    init(base: Character) {
        self.id = UUID().uuidString
        self.baseId = base.id
        self.base = base
    }

    // MARK: - PROGRESSION

    func addStars(_ amount: Int = 1) {
        stars = min(stars + amount, Self.maxStars)
    }

    func addEXP(_ amount: Int) {
        exp += amount

        while exp >= requiredEXP {
            exp -= requiredEXP
            level += 1
            print("⭐ \(base.name) LEVEL UP → \(level)")
        }
    }
}
