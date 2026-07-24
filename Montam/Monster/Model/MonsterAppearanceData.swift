//
//  MonsterAppearanceData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct MonsterAppearanceData: Codable, Identifiable {
    let id: String
    let monsterId: String
    let title: String
    let imageName: String
    let requiredLevel: Int?
    let isDefault: Bool?
    let isEvolutionStep: Bool?
}
