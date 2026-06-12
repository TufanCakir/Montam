//
//  TutorialConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
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
        title: "Montam Tutorial",
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
            "skin_cryon_feral_default",
            "skin_crygon_tamed_default",
            "skin_stormeon_mastered_default",
            "skin_imperion_exalted_default",
        ]
    )
}
