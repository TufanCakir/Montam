//
//  Skill.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

enum SkillType: String, Codable, Hashable {
    case damage
    case heal
    case buff
}

struct Skill: Codable, Identifiable, Hashable {

    let id: String
    let name: String
    let type: SkillType
    let multiplier: Double

    let cooldown: Double?
    let color: String?
}
