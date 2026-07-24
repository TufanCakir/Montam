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
            ?? "mon_kyro"

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

    func runtimeSelectedMonsters() -> [RuntimeOwnedMonster] {
        let progression = JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
            ?? GameProgressionData()

        return ownedMonsters
            .filter(\.isSelected)
            .map {
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

    func runtimeSelectedTamers() -> [RuntimeOwnedTamer] {
        ownedTamers
            .filter(\.isSelected)
            .map {
                RuntimeOwnedTamer(
                    tamerId: $0.tamerId,
                    level: $0.level,
                    xp: $0.xp
                )
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
        refreshPlayerStats(
            save: save,
            monsterCatalog: monsterCatalog,
            progression: progression
        )

        try? modelContext.save()
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
        ShopInventoryService.syncEntitlements(
            productIds: productIds,
            saves: saves,
            modelContext: modelContext
        )
    }

    func syncJSONCompanions() {
        TeamInventoryService.syncJSONCompanions(
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            modelContext: modelContext
        )
    }

    func selectMonster(id: String) {
        TeamInventoryService.selectMonster(
            id: id,
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
            && monster.xp >= xpNeeded(for: monster.level, progression: progression)
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
        save.playerMaxXP = xpNeeded(for: save.playerLevel, progression: progression)
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
                monsterId: "kyro",
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
                ownedTamers: [tamer]
            )
        } catch {
            fatalError("Failed to create preview GameStore: \(error)")
        }
    }
}
#endif
