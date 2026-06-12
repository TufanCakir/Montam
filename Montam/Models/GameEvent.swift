//
//  GameEvent.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct GameEvent: Codable, Identifiable, Hashable {

    var id: String
    var title: String
    var type: String

    var category: EventCategory
    var mode: EventMode

    var description: String?
    var icon: String?
    var battleBackground: String?
    var modifiers: EventModifier?
    var startDate: String?
    var endDate: String?
    var durationDays: Int?
    var storyText: String?
    var difficultyIds: [String]?
    var bossEnemy: String?
    var bossLevelId: String?
    var enemyElement: String?
    var hero: String?
    var rateUpMultiplier: Double?
    var targetStages: Int?
    var rewards: EventRewards?
}

struct EventRewards: Codable, Hashable {

    var montamCoins: Int?
    var montamSaphirs: Int?
    var montamRubys: Int?
    var exp: Int?
    var montamContainers: Int?
    var montamLiquid: Int?
    var eggs: [EggReward]?
    var medalId: String?
    var medals: Int?
}

struct EggReward: Codable, Hashable, Identifiable {
    let eggId: String
    let amount: Int

    var id: String { eggId }
}

struct EventModifier: Codable, Hashable {

    let expMultiplier: Double?
    let coinMultiplier: Double?
    let crystalMultiplier: Double?

    let spawnMultiplier: Double?
}

enum EventCategory: String, Codable, CaseIterable, Hashable {
    case story = "story"
    case original = "original"
    case special = "special"
    case boss = "boss"
    case buff = "buff"
}
