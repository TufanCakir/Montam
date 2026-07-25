//
//  SummonViewModel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class SummonViewModel {
    let categories: [SummonCategoryData]
    let summons: [SummonData]
    let summonPool: [SummonPoolData]
    let monsters: [MonsterData]
    let tamers: [TamerData]

    var selectedCategoryId: String
    var summonResultTitle = "Beschwörung"
    var summonResults: [SummonResultItem] = []
    var isShowingSummonResult = false
    var summonMessage: String?

    init() {
        let loadedCategories =
            JSONDataLoader.load("summonCategory", as: [SummonCategoryData].self)
            ?? []
        let loadedSummons =
            JSONDataLoader.load("summon", as: [SummonData].self) ?? []

        categories = loadedCategories
        summons = loadedSummons
        summonPool =
            JSONDataLoader.load("summonPool", as: [SummonPoolData].self) ?? []
        monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
        tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
        selectedCategoryId =
            loadedCategories.first?.id ?? loadedSummons.first?.category ?? ""
    }

    var filteredSummons: [SummonData] {
        summons(for: selectedCategoryId)
    }

    func summons(for categoryId: String) -> [SummonData] {
        let matching = summons.filter { $0.category == categoryId }
        return matching.isEmpty ? summons : matching
    }

    func moveCategory(by offset: Int) {
        guard
            let currentIndex = categories.firstIndex(where: {
                $0.id == selectedCategoryId
            })
        else {
            selectedCategoryId = categories.first?.id ?? selectedCategoryId
            return
        }

        let nextIndex = min(
            max(currentIndex + offset, 0),
            max(categories.count - 1, 0)
        )
        selectedCategoryId = categories[nextIndex].id
    }

    func makeResults(for summon: SummonData, count: Int) -> [SummonResultItem] {
        (0..<count).map { index in
            makeResultItem(for: summon, index: index, count: count)
        }
    }

    func rates(for summon: SummonData) -> [SummonRateData] {
        let configured = summon.rates ?? []
        return configured.isEmpty ? Self.defaultRates : configured
    }

    func currencyName(_ currency: String) -> String {
        switch currency {
        case "crystal", "crystals":
            return "Kristalle"
        case "summon_ticket", "ticket", "tickets":
            return "Tickets"
        case "bit", "bits":
            return "Bits"
        case "coin", "coins":
            return "Coins"
        default:
            return currency
        }
    }

    func showMessage(_ message: String) {
        summonMessage = message

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.6))
            guard let self, self.summonMessage == message else {
                return
            }
            self.summonMessage = nil
        }
    }

    private func makeResultItem(for summon: SummonData, index: Int, count: Int)
        -> SummonResultItem
    {
        let rarity = resultRarity(for: summon, index: index, count: count)

        if shouldUseTamerPool(for: summon),
           let tamer = supportForResult(rarity: rarity)
        {
            return SummonResultItem(
                title: tamer.name,
                subtitle: "Tamer Support",
                rarity: tamer.rarity ?? rarity,
                kind: .tamer,
                imageName: tamer.tamerName,
                accentColor: rarityColor(tamer.rarity ?? rarity)
            )
        }

        if let monster = monsterForResult(summon: summon, rarity: rarity) {
            return SummonResultItem(
                title: monster.name,
                subtitle: "Monster",
                rarity: monster.rarity ?? rarity,
                kind: .monster,
                imageName: monster.monsterName,
                accentColor: rarityColor(monster.rarity ?? rarity)
            )
        }

        return SummonResultItem(
            title: summon.title,
            subtitle: "Beschwörung",
            rarity: rarity,
            kind: .monster,
            imageName: summon.bannerImage,
            accentColor: rarityColor(rarity)
        )
    }

    private func shouldUseTamerPool(for summon: SummonData) -> Bool {
        summon.category == "support" || summon.category == "empfohlen"
    }

    private func monsterForResult(summon: SummonData, rarity: String) -> MonsterData? {
        if let exact = monsters.first(where: { $0.monsterName == summon.bannerImage }) {
            return exact
        }

        let poolIds = summonPool.map(\.characterId)
        let pooledMonsters = monsters.filter {
            poolIds.contains($0.monsterName) || poolIds.contains($0.id)
        }
        let source = pooledMonsters.isEmpty ? monsters : pooledMonsters
        return weightedItem(rarity: rarity, in: source, rarity: { $0.rarity })
    }

    private func supportForResult(rarity: String) -> TamerData? {
        let poolIds = summonPool.map(\.characterId)
        let pooledTamers = tamers.filter {
            poolIds.contains($0.tamerName) || poolIds.contains($0.id)
        }
        let source = pooledTamers.isEmpty ? tamers : pooledTamers
        return weightedItem(rarity: rarity, in: source, rarity: { $0.rarity })
    }

    private func randomItem<T>(in items: [T]) -> T? {
        guard !items.isEmpty else {
            return nil
        }

        return items.randomElement()
    }

    private func weightedItem<T>(
        rarity targetRarity: String,
        in items: [T],
        rarity: (T) -> String?
    ) -> T? {
        guard !items.isEmpty else {
            return nil
        }

        let matching = items.filter {
            Self.normalizedRarity(rarity($0)) == Self.normalizedRarity(targetRarity)
        }
        if let item = randomItem(in: matching) {
            return item
        }

        let targetRank = Self.rarityRank(targetRarity)
        let rankedItems = items.map { item in
            (item: item, rank: Self.rarityRank(rarity(item) ?? "common"))
        }
        let eligible = rankedItems.filter { $0.rank >= targetRank }
        let fallbackRank = eligible.map(\.rank).min()
            ?? rankedItems.map(\.rank).min()
            ?? 0
        let fallbackItems = rankedItems
            .filter { $0.rank == fallbackRank }
            .map(\.item)
        return randomItem(in: fallbackItems.isEmpty ? items : fallbackItems)
    }

    private func resultRarity(for summon: SummonData, index: Int, count: Int) -> String {
        let rates = rates(for: summon)
        if count >= 10, index == count - 1 {
            let guaranteedRates = rates.filter {
                Self.rarityRank($0.rarity) >= Self.rarityRank("rare")
            }
            return weightedRarity(from: guaranteedRates.isEmpty ? rates : guaranteedRates)
        }

        return weightedRarity(from: rates)
    }

    private func weightedRarity(from rates: [SummonRateData]) -> String {
        let safeRates = rates.filter { $0.weight > 0 }
        let totalWeight = safeRates.reduce(0) { $0 + $1.weight }
        guard totalWeight > 0 else {
            return "common"
        }

        var roll = Int.random(in: 1...totalWeight)
        for rate in safeRates {
            roll -= rate.weight
            if roll <= 0 {
                return rate.rarity
            }
        }

        return safeRates.last?.rarity ?? "common"
    }

    private func rarityColor(_ rarity: String) -> Color {
        switch Self.normalizedRarity(rarity) {
        case "legendary":
            return .orange
        case "epic":
            return .purple
        case "rare":
            return .blue
        case "common":
            return .green
        default:
            return .cyan
        }
    }

    private static let defaultRates = [
        SummonRateData(rarity: "common", title: "Common", weight: 7000),
        SummonRateData(rarity: "rare", title: "Rare", weight: 2200),
        SummonRateData(rarity: "epic", title: "Epic", weight: 750),
        SummonRateData(rarity: "legendary", title: "Legendär", weight: 50),
    ]

    private static func rarityRank(_ rarity: String) -> Int {
        switch normalizedRarity(rarity) {
        case "common": 0
        case "rare": 1
        case "epic": 2
        case "legendary": 3
        default: 0
        }
    }

    private static func normalizedRarity(_ rarity: String?) -> String {
        switch rarity?.lowercased() {
        case "n", "normal", "common":
            return "common"
        case "r", "sr", "rare":
            return "rare"
        case "ssr", "epic":
            return "epic"
        case "ur", "lr", "legendary", "legendär":
            return "legendary"
        default:
            return "common"
        }
    }
}
