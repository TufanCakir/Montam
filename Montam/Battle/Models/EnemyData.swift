//
//  EnemyData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct EnemyData: Codable {
    let id: String
    let enemyName: String
    let imageName: String?
    let name: String
    let rarity: String?
    let hp: Int?
    let attack: Int?
    let defense: Int?
    let level: Int?
    let enemyGrowthRate: Double?
    let yOffset: Int
    let xOffset: Int
    let zOffset: Int
}
