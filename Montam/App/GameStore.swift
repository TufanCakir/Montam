//
//  GameStore.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftData

@MainActor
struct GameStore {
    let modelContext: ModelContext
    let saves: [GameSaveData]
    let ownedMonsters: [OwnedMonsterData]
    let ownedTamers: [OwnedTamerData]
    let ownedSupporters: [OwnedSupporterData]

    private var save: GameSaveData? {
        saves.first
    }

    func ensureSave() -> GameSaveData {
        if let save {
            return save
        }

        let save = GameSaveData(didCompleteOnboarding: true)
        modelContext.insert(save)
        return save
    }

    func playerStatusState(monsters: [MonsterData]) -> PlayerStatusBarState {
        let active = ownedMonsters.first(where: \.isSelected)
        let activeImage =
            active?.equippedImageName
            ?? active.flatMap { owned in
                monsters.first(where: { $0.id == owned.monsterId })?.monsterName
            }
            ?? monsters.first?.monsterName
            ?? "mon_kyron"

        return PlayerStatusBarState(
            imageName: activeImage,
            level: save?.playerLevel ?? active?.level ?? 1,
            power: save?.playerPower ?? 0,
            xp: save?.playerXP ?? active?.xp ?? 0,
            maxXP: save?.playerMaxXP ?? 100,
            coins: save?.coins ?? 0,
            crystals: save?.crystals ?? 0,
            bits: save?.bits ?? 0
        )
    }

    var shopWallet: ShopWalletState {
        ShopWalletState(
            coins: save?.coins ?? 0,
            crystals: save?.crystals ?? 0,
            bits: save?.bits ?? 0
        )
    }

    var summonTickets: Int {
        save?.summonTickets ?? 0
    }

    var crystals: Int {
        save?.crystals ?? 0
    }

    var currentStage: Int {
        save?.currentStage ?? 1
    }

    var hasEventPass: Bool {
        save?.hasEventPass ?? false
    }

    var montamPassPoints: Int {
        save?.montamPassPoints ?? 0
    }

    var claimedBattlePassRewardIds: Set<String> {
        Set(save?.claimedBattlePassRewardIds ?? [])
    }

    func runtimeSelectedMonsters() -> [RuntimeOwnedMonster] {
        let progression =
            JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
            ?? GameProgressionData()
        let monsterCatalog =
            JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

        let selected = ownedMonsters.filter(\.isSelected)
        if !selected.isEmpty {
            return selected.map {
                RuntimeOwnedMonster(
                    monsterId: $0.monsterId,
                    level: $0.level,
                    xp: $0.xp,
                    maxXP: GameProgressionCalculator.xpNeeded(
                        for: $0.level,
                        progression: progression
                    ),
                    imageName: $0.equippedImageName
                )
            }
        }

        guard let firstMonster = monsterCatalog.first else {
            return []
        }

        return [
            RuntimeOwnedMonster(
                monsterId: firstMonster.id,
                level: 1,
                xp: 0,
                maxXP: GameProgressionCalculator.xpNeeded(
                    for: 1,
                    progression: progression
                ),
                imageName: firstMonster.monsterName
            )
        ]
    }

    func runtimeSelectedTamers() -> [RuntimeOwnedTamer] {
        []
    }

    func runtimeSelectedSupporters() -> [RuntimeOwnedSupporter] {
        let battleConfig =
            JSONDataLoader.load("battleConfig", as: BattleConfigData.self)
        let supporterData = SupporterData.loadAll()
        let summons =
            JSONDataLoader.load("summon", as: [SummonData].self) ?? []
        var seenCharacterIds = Set<String>()
        var categoryCounts: [String: Int] = [:]
        let selectedSupporters =
            ownedSupporters
            .filter(\.isSelected)
            .filter {
                seenCharacterIds.insert($0.characterId).inserted
            }
            .filter { owned in
                let category = supportCategory(for: owned, summons: summons)
                let currentCount = categoryCounts[category] ?? 0
                let limit = supportLimit(
                    for: category,
                    battleConfig: battleConfig
                )

                guard currentCount < limit else {
                    return false
                }

                categoryCounts[category] = currentCount + 1
                return true
            }
            .prefix(battleConfig?.maxSupporters ?? 3)

        return selectedSupporters.map { owned in
            let matchingBannerEntry = supporterData.first { entry in
                entry.bannerId == owned.bannerId
                    && entry.characterId == owned.characterId
            }
            let matchingCharacterEntry = supporterData.first { entry in
                entry.characterId == owned.characterId
            }
            let supportEntry = matchingBannerEntry ?? matchingCharacterEntry

            return RuntimeOwnedSupporter(
                characterId: owned.characterId,
                imageName: owned.imageName,
                level: owned.level,
                isMonster: owned.isMonster,
                xOffset: supportEntry?.xOffset,
                yOffset: supportEntry?.yOffset,
                zOffset: supportEntry?.zOffset,
                scaleMultiplier: supportEntry?.scaleMultiplier,
                attackBonus: supportEntry?.attackBonus,
                defenseBonus: supportEntry?.defenseBonus,
                healthBonus: supportEntry?.healthBonus
            )
        }
    }

    private func supportCategory(
        for supporter: OwnedSupporterData,
        summons: [SummonData]
    ) -> String {
        summons.first(where: { $0.id == supporter.bannerId })?.category
            ?? "montam"
    }

    private func supportLimit(
        for category: String,
        battleConfig: BattleConfigData?
    ) -> Int {
        switch category {
        case "tamer":
            return battleConfig?.maxTamerSupporters ?? 1
        case "mega_supporter":
            return battleConfig?.maxMegaSupporters ?? 1
        default:
            return battleConfig?.maxMontamSupporters ?? 1
        }
    }

    func updateStage(_ nextStage: Int) {
        let save = ensureSave()
        save.currentStage = nextStage
    }

    func applyBattleReward(
        _ reward: BattleWaveReward,
        monsterCatalog: [MonsterData],
        progression: GameProgressionData
    ) {
        let save = ensureSave()

        for monster in ownedMonsters where monster.isSelected {
            monster.xp += reward.xp
            levelUpIfNeeded(monster, progression: progression)
        }

        save.coins += reward.coins
        save.crystals += reward.crystals
        save.bits += reward.bits
        save.montamPassPoints += reward.xp
        refreshPlayerStats(
            save: save,
            monsterCatalog: monsterCatalog,
            progression: progression
        )

        try? modelContext.save()
    }

    func claimBattlePassReward(_ reward: BattlePassRewardDefinition) -> Bool {
        let save = ensureSave()
        guard save.hasEventPass,
            save.montamPassPoints >= reward.requiredPoints,
            !save.claimedBattlePassRewardIds.contains(reward.id)
        else {
            return false
        }

        save.coins += reward.coins
        save.bits += reward.bits
        save.summonTickets += reward.summonTickets
        save.claimedBattlePassRewardIds.append(reward.id)

        let progression =
            JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
            ?? GameProgressionData()
        let monsterCatalog =
            JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

        for monster in ownedMonsters where monster.isSelected {
            monster.xp += reward.xp
            levelUpIfNeeded(monster, progression: progression)
        }

        refreshPlayerStats(
            save: save,
            monsterCatalog: monsterCatalog,
            progression: progression
        )
        try? modelContext.save()
        return true
    }

    func spendSummon(cost: Int, currency: String) -> Bool {
        SummonInventoryService.spend(
            cost: cost,
            currency: currency,
            saves: saves,
            modelContext: modelContext
        )
    }

    func applySummonResults(
        _ results: [SummonResultItem],
        monsters: [MonsterData],
        tamers: [TamerData]
    ) {
        SummonInventoryService.applyResults(
            results,
            monsters: monsters,
            tamers: tamers,
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            ownedSupporters: ownedSupporters,
            modelContext: modelContext
        )
    }

    func purchaseItem(_ product: ItemShopProductData) -> Bool {
        ShopInventoryService.purchaseItemProduct(
            product,
            saves: saves,
            modelContext: modelContext
        )
    }

    func purchaseSoftCurrencyProduct(_ product: ShopProductData) -> Bool {
        ShopInventoryService.purchaseSoftCurrencyProduct(
            product,
            saves: saves,
            modelContext: modelContext
        )
    }

    func applyShopRewards(from product: ShopProductData) {
        ShopInventoryService.applyRewards(
            from: product,
            saves: saves,
            modelContext: modelContext
        )
    }

    func syncShopEntitlements(productIds: Set<String>) {
        let shopProducts =
            JSONDataLoader.load("shop", as: ShopData.self)?.products ?? []

        ShopInventoryService.syncEntitlements(
            productIds: productIds,
            products: shopProducts,
            saves: saves,
            modelContext: modelContext
        )
    }

    func syncJSONCompanions() {
        TeamInventoryService.syncJSONCompanions(
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            ownedSupporters: ownedSupporters,
            modelContext: modelContext
        )
    }

    func selectMonster(id: String, imageName: String? = nil) {
        TeamInventoryService.selectMonster(
            id: id,
            imageName: imageName,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }

    func selectTamer(id: String) {
        TeamInventoryService.selectTamer(
            id: id,
            ownedTamers: ownedTamers,
            modelContext: modelContext
        )
    }

    func selectSupporter(id: String) {
        TeamInventoryService.selectSupporter(
            id: id,
            ownedSupporters: ownedSupporters,
            maxSelectedSupporters: (JSONDataLoader.load(
                "battleConfig",
                as: BattleConfigData.self
            )?
            .maxSupporters) ?? 3,
            modelContext: modelContext
        )
    }

    func transformActiveMonster(to imageName: String, monsterId: String) {
        TeamInventoryService.equipAppearance(
            imageName: imageName,
            monsterId: monsterId,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }

    func equipAppearance(imageName: String, monsterId: String) {
        TeamInventoryService.equipAppearance(
            imageName: imageName,
            monsterId: monsterId,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }

    private func levelUpIfNeeded(
        _ monster: OwnedMonsterData,
        progression: GameProgressionData
    ) {
        while monster.level < progression.resolvedMaxLevel
            && monster.xp
                >= xpNeeded(for: monster.level, progression: progression)
        {
            monster.xp -= xpNeeded(for: monster.level, progression: progression)
            monster.level += 1
        }

        if monster.level >= progression.resolvedMaxLevel {
            monster.level = progression.resolvedMaxLevel
            monster.xp = min(
                monster.xp,
                xpNeeded(
                    for: progression.resolvedMaxLevel,
                    progression: progression
                )
            )
        }
    }

    private func xpNeeded(
        for level: Int,
        progression: GameProgressionData
    ) -> Int {
        GameProgressionCalculator.xpNeeded(for: level, progression: progression)
    }

    private func refreshPlayerStats(
        save: GameSaveData,
        monsterCatalog: [MonsterData],
        progression: GameProgressionData
    ) {
        let selected = ownedMonsters.filter(\.isSelected)
        save.playerLevel = selected.map(\.level).max() ?? save.playerLevel
        save.playerXP = selected.first?.xp ?? save.playerXP
        save.playerMaxXP = xpNeeded(
            for: save.playerLevel,
            progression: progression
        )
        save.playerPower = selected.reduce(0) { total, owned in
            guard
                let base = monsterCatalog.first(where: {
                    $0.id == owned.monsterId
                })
            else {
                return total
            }

            return total
                + GameProgressionCalculator.power(for: base, level: owned.level)
        }
    }
}

#if DEBUG
    extension GameStore {
        static var preview: GameStore {
            do {
                let schema = Schema([
                    GameSaveData.self,
                    OwnedMonsterData.self,
                    OwnedTamerData.self,
                ])
                let configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                let container = try ModelContainer(
                    for: schema,
                    configurations: [configuration]
                )
                let context = ModelContext(container)
                let save = GameSaveData(
                    didCompleteOnboarding: true,
                    playerLevel: 10,
                    playerPower: 472,
                    playerXP: 146,
                    playerMaxXP: 234,
                    bits: 70_900,
                    coins: 50_800,
                    crystals: 202,
                    summonTickets: 9
                )
                let monster = OwnedMonsterData(
                    monsterId: "cubon",
                    level: 10,
                    xp: 146,
                    isSelected: true,
                    equippedImageName: "mon_cubon"
                )
                let tamer = OwnedTamerData(
                    tamerId: "kael",
                    level: 8,
                    xp: 80,
                    isSelected: true
                )

                context.insert(save)
                context.insert(monster)
                context.insert(tamer)

                return GameStore(
                    modelContext: context,
                    saves: [save],
                    ownedMonsters: [monster],
                    ownedTamers: [tamer],
                    ownedSupporters: []
                )
            } catch {
                fatalError("Failed to create preview GameStore: \(error)")
            }
        }
    }
#endif
