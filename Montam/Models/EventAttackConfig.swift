//
//  EventAttackConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct EventAttackRoot: Codable {
    let attacks: [EventAttack]
}

struct EventAttack: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let power: Int
    let energyCost: Int?
    let element: String?
}

enum EventAttackLoader {
    static func load() -> [EventAttack] {
        do {
            let root: EventAttackRoot = try JSONLoader.load("event_attacks")
            return root.attacks
        } catch {
            print("event_attacks.json konnte nicht geladen werden:", error)
            return []
        }
    }
}
