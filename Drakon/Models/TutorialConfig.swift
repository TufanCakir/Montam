//
//  TutorialConfig.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Foundation

struct TutorialRoot: Codable {
    let tutorials: [TutorialConfig]
}

struct TutorialConfig: Codable, Identifiable {
    let id: String
    let title: String
    let steps: [TutorialStepConfig]
    let previewForms: [String]
}

struct TutorialStepConfig: Codable, Identifiable {
    let id: String
    let title: String
    let text: String
    let focus: String?
}

enum TutorialConfigLoader {
    static func load(id: String = "first_start") -> TutorialConfig {
        do {
            let root: TutorialRoot = try JSONLoader.load("tutorials")
            return root.tutorials.first { $0.id == id }
                ?? TutorialConfig.fallback
        } catch {
            print("tutorials.json konnte nicht geladen werden:", error)
            return .fallback
        }
    }
}

extension TutorialConfig {
    static let fallback = TutorialConfig(
        id: "first_start",
        title: "Drakon Tutorial",
        steps: [
            TutorialStepConfig(
                id: "battle",
                title: "Battle",
                text:
                    "Tippe auf den Gegner, lade Evolution Energy und ziehe danach eine Form-Karte.",
                focus: "battle"
            ),
            TutorialStepConfig(
                id: "cards",
                title: "Evolution Cards",
                text:
                    "Im echten Kampf kannst du nur Forms ziehen, die du vorher im Summon freigeschaltet hast.",
                focus: "cards"
            ),
        ],
        previewForms: [
            "skin_pyro_baby_default",
            "skin_blazion_rookie_default",
            "skin_infernon_advanced_default",
            "skin_solarion_imperial_default",
        ]
    )
}
