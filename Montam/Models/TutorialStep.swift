//
//  TutorialStep.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct TutorialBattle: Decodable {
    let id: String
    let steps: [TutorialStep]
}

struct TutorialStep: Decodable, Identifiable {

    let id = UUID()
    let type: StepType
    let speaker: String?
    let text: String?
    let action: String?

    enum CodingKeys: String, CodingKey {
        case type
        case speaker
        case text
        case action
    }
}

enum StepType: String, Decodable {
    case dialog
    case action
    case finish
}
