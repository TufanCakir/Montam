//
//  ElementSystem.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Foundation

enum DrakonElement: String, Codable, CaseIterable, Hashable {
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
            "skin_pyro_baby_default"
        case .water:
            "skin_blazion_rookie_default"
        case .nature:
            "skin_infernon_advanced_default"
        case .light, .dark, .arcane, .lightning, .chaos, .neutral:
            "drakon_icon"
        }
    }

    static func parse(_ value: String?) -> DrakonElement {
        guard let value else { return .neutral }
        return DrakonElement(rawValue: value.lowercased()) ?? .neutral
    }
}

enum ElementSystem {
    static func multiplier(attacker: DrakonElement, defender: DrakonElement)
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
