//
//  GameConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct GameConfig: Codable {
    let team: TeamConfig
    let starterSelection: StarterSelectionRules
    let battleDifficulties: [BattleDifficulty]
    let storyChapters: [StoryChapter]
    let footerItems: [GameFooterConfigItem]?
    let homeMenuItems: [GameMenuConfigItem]?
    let loadingImages: [String]?
    let eventUI: EventUIConfig?

    static let fallback = GameConfig(
        team: TeamConfig(maxActiveTeamSize: 4),
        starterSelection: StarterSelectionRules(
            requiredForNewAccount: true,
            selectionCount: 1
        ),
        battleDifficulties: [
            BattleDifficulty(
                id: "normal",
                title: "Normal",
                enemyHpMultiplier: 1.0,
                rewardMultiplier: 1.0
            )
        ],
        storyChapters: [],
        footerItems: GameFooterConfigItem.fallback,
        homeMenuItems: GameMenuConfigItem.fallback,
        loadingImages: [],
        eventUI: .fallback
    )
}

struct TeamConfig: Codable {
    let maxActiveTeamSize: Int
}

struct StarterSelectionRules: Codable {
    let requiredForNewAccount: Bool
    let selectionCount: Int
}

struct BattleDifficulty: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let enemyHpMultiplier: Double
    let rewardMultiplier: Double
}

struct StoryChapter: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let enemyImage: String
    let enemyElement: String
    let storyText: String
    let targetStages: Int
    let rewards: EventRewards?
}

struct GameFooterConfigItem: Codable, Identifiable, Hashable {
    let tab: String
    let title: String
    let icon: String
    let color: String?

    var id: String { tab }

    static let fallback: [GameFooterConfigItem] = [
        GameFooterConfigItem(
            tab: "home",
            title: "Home",
            icon: "icon_house",
            color: "gold"
        ),
        GameFooterConfigItem(
            tab: "team",
            title: "Team",
            icon: "icon_team",
            color: "cyan"
        ),
        GameFooterConfigItem(
            tab: "summon",
            title: "Summon",
            icon: "icon_summon",
            color: "violet"
        ),
        GameFooterConfigItem(
            tab: "shop",
            title: "Shop",
            icon: "icon_shop",
            color: "emerald"
        ),
        GameFooterConfigItem(
            tab: "exchange",
            title: "Trade",
            icon: "icon_trade",
            color: "crimson"
        ),
    ]
}

struct GameMenuConfigItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
    let route: String
    let color: String?
    let style: String?

    static let fallback: [GameMenuConfigItem] = [
        GameMenuConfigItem(
            id: "story",
            title: "Story Battle",
            icon: "skin_pyro_feral_default",
            route: "story",
            color: "gold",
            style: "wide"
        ),
        GameMenuConfigItem(
            id: "upgrade",
            title: "Upgrade",
            icon: "skin_blazion_tamed_default",
            route: "upgrade",
            color: "blue",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "hatchery",
            title: "Hatchery",
            icon: "egg_feral_pyro",
            route: "hatchery",
            color: "gold",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "wardrobe",
            title: "Wardrobe",
            icon: "skin_solarion_exalted_default",
            route: "wardrobe",
            color: "blue",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "events",
            title: "Events",
            icon: "skin_solarion_exalted_default",
            route: "events",
            color: "gold",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "gifts",
            title: "Gifts",
            icon: "skin_pyro_feral_default",
            route: "gifts",
            color: "blue",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "passes",
            title: "Passes",
            icon: "skin_pyro_feral_default",
            route: "passes",
            color: "gold",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "news",
            title: "News",
            icon: "skin_pyro_feral_default",
            route: "news",
            color: "blue",
            style: "small"
        ),
        GameMenuConfigItem(
            id: "settings",
            title: "Settings",
            icon: "skin_solarion_exalted_default",
            route: "settings",
            color: "blue",
            style: "wide"
        ),
    ]
}

struct EventUIConfig: Codable, Hashable {
    let title: String?
    let emptyTitle: String?
    let emptyIcon: String?
    let battleButtonTitle: String?
    let defaultDescription: String?
    let permanentText: String?
    let endedText: String?
    let dayLeftSuffix: String?
    let hourLeftSuffix: String?
    let infoElementPrefix: String?
    let infoElementRules: String?
    let skinBadgeTitle: String?
    let eggBadgeTitle: String?
    let rewardIcons: EventRewardIconConfig?

    static let fallback = EventUIConfig(
        title: "Events",
        emptyTitle: "Keine Events",
        emptyIcon: "montam_icon",
        battleButtonTitle: "Event Battle",
        defaultDescription: "Event Battle",
        permanentText: "Permanent",
        endedText: "Beendet",
        dayLeftSuffix: "d left",
        hourLeftSuffix: "h left",
        infoElementPrefix: "Element",
        infoElementRules:
            "Feuer > Pflanze, Pflanze > Wasser, Wasser > Feuer. Licht und Dunkelheit treffen sich stark.",
        skinBadgeTitle: "Skin Event",
        eggBadgeTitle: "Egg Drop",
        rewardIcons: .fallback
    )
}

struct EventRewardIconConfig: Codable, Hashable {
    let montamCoins: String
    let montamSaphirs: String
    let montamRubys: String
    let montamShards: String
    let montamContainers: String
    let montamLiquid: String
    let egg: String
    let skin: String

    static let fallback = EventRewardIconConfig(
        montamCoins: "icon_montam_coins",
        montamSaphirs: "icon_montam_saphir",
        montamRubys: "icon_montam_rubys",
        montamShards: "icon_montam_shards",
        montamContainers: "icon_montam_containers",
        montamLiquid: "icon_montam_liquid",
        egg: "egg_feral_pyro",
        skin: "skin_solarion_exalted_blue"
    )
}
