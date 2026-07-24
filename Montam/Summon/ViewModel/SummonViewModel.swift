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
        let rarity = resultRarity(index: index, count: count)

        if shouldUseTamerPool(for: summon), let tamer = supportForResult(index: index) {
            return SummonResultItem(
                title: tamer.name,
                subtitle: "Tamer Support",
                rarity: tamer.rarity ?? rarity,
                kind: .tamer,
                imageName: tamer.tamerName,
                accentColor: rarityColor(tamer.rarity ?? rarity)
            )
        }

        if let monster = monsterForResult(summon: summon, index: index) {
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

    private func monsterForResult(summon: SummonData, index: Int) -> MonsterData? {
        if let exact = monsters.first(where: { $0.monsterName == summon.bannerImage }) {
            return exact
        }

        let poolIds = summonPool.map(\.characterId)
        let pooledMonsters = monsters.filter {
            poolIds.contains($0.monsterName) || poolIds.contains($0.id)
        }
        let source = pooledMonsters.isEmpty ? monsters : pooledMonsters
        return item(at: index, in: source)
    }

    private func supportForResult(index: Int) -> TamerData? {
        let poolIds = summonPool.map(\.characterId)
        let pooledTamers = tamers.filter {
            poolIds.contains($0.tamerName) || poolIds.contains($0.id)
        }
        let source = pooledTamers.isEmpty ? tamers : pooledTamers
        return item(at: index, in: source)
    }

    private func item<T>(at index: Int, in items: [T]) -> T? {
        guard !items.isEmpty else {
            return nil
        }

        return items[index % items.count]
    }

    private func resultRarity(index: Int, count: Int) -> String {
        if count >= 10, index == count - 1 {
            return "SR"
        }

        let cycle = ["N", "R", "R", "SR", "N", "R", "SSR"]
        return cycle[index % cycle.count]
    }

    private func rarityColor(_ rarity: String) -> Color {
        switch rarity.lowercased() {
        case "ur", "legendary", "epic":
            return .orange
        case "ssr":
            return .purple
        case "sr", "rare":
            return .blue
        case "r":
            return .green
        default:
            return .cyan
        }
    }
}
