//
//  EventRuntime.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

class EventRuntime {

    static let shared = EventRuntime()

    var activeEvent: GameEvent?
    var crackSpawnMultiplier: Double = 1.0

    func activate(_ event: GameEvent) {

        activeEvent = event

        if let multi = event.modifiers?.spawnMultiplier {
            crackSpawnMultiplier = multi
        }
    }

    func clear() {
        activeEvent = nil
        crackSpawnMultiplier = 1.0
    }
}
