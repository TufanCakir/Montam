//
//  ElementSystem.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

enum MontamElement: String, Codable, CaseIterable, Hashable {
    case fire
    case water
    case nature
    case light
    case dark
    case arcane
    case lightning
    case chaos
    case neutral

    var title: String { rawValue.uppercased() }

    var icon: String {
        switch self {
        case .fire:
            "skin_pyro_feral_default"
        case .water:
            "skin_blazion_tamed_default"
        case .nature:
            "skin_infernon_mastered_default"
        case .light, .dark, .arcane, .lightning, .chaos, .neutral:
            "montam_icon"
        }
    }

    static func parse(_ value: String?) -> MontamElement {
        guard let value else { return .neutral }
        return MontamElement(rawValue: value.lowercased()) ?? .neutral
    }
}

enum ElementSystem {
    static func multiplier(attacker: MontamElement, defender: MontamElement)
        -> Double
    {
        if attacker == .light && defender == .dark { return 1.25 }
        if attacker == .dark && defender == .light { return 1.25 }

        switch (attacker, defender) {
        case (.fire, .nature), (.nature, .water), (.water, .fire):
            return 1.35
        case (.fire, .water), (.water, .nature), (.nature, .fire):
            return 0.75
        default:
            return 1.0
        }
    }
}
