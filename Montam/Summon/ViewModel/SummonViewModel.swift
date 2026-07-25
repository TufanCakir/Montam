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
    let appearances: [MonsterAppearanceData]

    var selectedCategoryId: String
    var summonResultTitle = "Beschwörung"
    var summonResults: [SummonResultItem] = []
    var isShowingSummonResult = false
    var summonMessage: String?

    init() {
        let loadedCategories =
            JSONDataLoader.load(
                "summonCategory",
                as: [SummonCategoryData].self
            ) ?? []

        let loadedSummons =
            JSONDataLoader.load(
                "summon",
                as: [SummonData].self
            ) ?? []

        categories = loadedCategories
        summons = loadedSummons

        summonPool =
            JSONDataLoader.load(
                "summonPool",
                as: [SummonPoolData].self
            ) ?? []

        monsters =
            JSONDataLoader.load(
                "monster",
                as: [MonsterData].self
            ) ?? []

        tamers =
            JSONDataLoader.load(
                "tamer",
                as: [TamerData].self
            ) ?? []

        appearances =
            JSONDataLoader.load(
                "monsterAppearance",
                as: [MonsterAppearanceData].self
            ) ?? []

        selectedCategoryId =
            loadedCategories.first?.id
            ?? loadedSummons.first?.category
            ?? ""
    }

    // MARK: - Categories

    var filteredSummons: [SummonData] {
        summons(for: selectedCategoryId)
    }

    func summons(for categoryId: String) -> [SummonData] {
        summons.filter {
            $0.category == categoryId
        }
    }

    func moveCategory(by offset: Int) {
        guard !categories.isEmpty else {
            return
        }

        guard let currentIndex = categories.firstIndex(where: {
            $0.id == selectedCategoryId
        }) else {
            selectedCategoryId = categories[0].id
            return
        }

        let nextIndex = min(
            max(currentIndex + offset, 0),
            categories.count - 1
        )

        selectedCategoryId = categories[nextIndex].id
    }

    // MARK: - Summon

    func makeResults(
        for summon: SummonData,
        count: Int
    ) -> [SummonResultItem] {
        guard count > 0 else {
            return []
        }

        return (0..<count).map { index in
            makeResultItem(
                for: summon,
                index: index,
                count: count
            )
        }
    }

    func rates(for summon: SummonData) -> [SummonRateData] {
        let configuredRates = summon.rates ?? []

        return configuredRates.isEmpty
            ? Self.defaultRates
            : configuredRates
    }

    // MARK: - Result creation

    private func makeResultItem(
        for summon: SummonData,
        index: Int,
        count: Int
    ) -> SummonResultItem {
        let rolledRarity = resultRarity(
            for: summon,
            index: index,
            count: count
        )

        guard let candidate = poolCandidate(
            for: summon,
            targetRarity: rolledRarity
        ) else {
            return fallbackResult(
                for: summon,
                rarity: rolledRarity
            )
        }

        return resultItem(from: candidate, summon: summon)
    }

    private func resultItem(
        from candidate: PoolCandidate,
        summon: SummonData
    ) -> SummonResultItem {
        let isSupporter = Self.supporterCategoryIds.contains(summon.category)

        switch candidate.character {
        case .monster(let monster):
            let rarity = monster.rarity ?? candidate.rarity

            return SummonResultItem(
                title: monster.name,
                subtitle: isSupporter ? "Montam Support" : "Monster",
                rarity: rarity,
                kind: isSupporter ? .supportCard : .monster,
                imageName: monster.monsterName,
                bannerId: summon.id,
                characterId: monster.id,
                isSupporter: isSupporter,
                accentColor: rarityColor(rarity)
            )

        case .monsterAppearance(let appearance):
            let rarity = candidate.rarity

            return SummonResultItem(
                title: appearance.title,
                subtitle: summon.category == "mega_supporter"
                    ? "Mega Support" : "Montam Support",
                rarity: rarity,
                kind: .supportCard,
                imageName: appearance.imageName,
                bannerId: summon.id,
                characterId: candidate.characterId,
                isSupporter: isSupporter,
                accentColor: rarityColor(rarity)
            )

        case .tamer(let tamer):
            let rarity = tamer.rarity ?? candidate.rarity

            return SummonResultItem(
                title: tamer.name,
                subtitle: "Tamer Support",
                rarity: rarity,
                kind: isSupporter ? .supportCard : .tamer,
                imageName: tamer.tamerName,
                bannerId: summon.id,
                characterId: tamer.id,
                isSupporter: isSupporter,
                accentColor: rarityColor(rarity)
            )
        }
    }

    private func fallbackResult(
        for summon: SummonData,
        rarity: String
    ) -> SummonResultItem {
        SummonResultItem(
            title: summon.title,
            subtitle: "Banner nicht konfiguriert",
            rarity: rarity,
            kind: .supportCard,
            imageName: summon.bannerImage,
            bannerId: summon.id,
            characterId: nil,
            isSupporter: Self.supporterCategoryIds.contains(summon.category),
            accentColor: rarityColor(rarity)
        )
    }

    // MARK: - Banner pool

    private func poolCandidate(
        for summon: SummonData,
        targetRarity: String
    ) -> PoolCandidate? {
        let candidates = resolvedPoolCandidates(for: summon)

        guard !candidates.isEmpty else {
            print(
                "⚠️ Kein Summon-Pool für Banner:",
                summon.id
            )
            return nil
        }

        let rarityCandidates = candidates.filter {
            Self.normalizedRarity($0.rarity)
                == Self.normalizedRarity(targetRarity)
        }

        if !rarityCandidates.isEmpty {
            return weightedCandidate(from: rarityCandidates)
        }

        let fallbackCandidates = nearestCandidates(
            to: targetRarity,
            in: candidates
        )

        return weightedCandidate(
            from: fallbackCandidates.isEmpty
                ? candidates
                : fallbackCandidates
        )
    }

    private func resolvedPoolCandidates(
        for summon: SummonData
    ) -> [PoolCandidate] {
        let entries = summonPool.filter {
            $0.bannerId == summon.id && $0.weight > 0
        }

        return entries.compactMap { entry in
            if let monster = monster(for: entry.characterId) {
                return PoolCandidate(
                    character: .monster(monster),
                    characterId: entry.characterId,
                    rarity: monster.rarity ?? "common",
                    weight: entry.weight
                )
            }

            if let appearance = appearance(for: entry.characterId) {
                return PoolCandidate(
                    character: .monsterAppearance(appearance),
                    characterId: entry.characterId,
                    rarity: summon.category == "mega_supporter"
                        ? "legendary" : "common",
                    weight: entry.weight
                )
            }

            if let tamer = tamer(for: entry.characterId) {
                return PoolCandidate(
                    character: .tamer(tamer),
                    characterId: entry.characterId,
                    rarity: tamer.rarity ?? "common",
                    weight: entry.weight
                )
            }

            print(
                "⚠️ Charakter nicht gefunden:",
                entry.characterId,
                "Banner:",
                entry.bannerId
            )

            return nil
        }
    }

    private func monster(
        for characterId: String
    ) -> MonsterData? {
        monsters.first {
            $0.id == characterId
                || $0.monsterName == characterId
        }
    }

    private func tamer(
        for characterId: String
    ) -> TamerData? {
        tamers.first {
            $0.id == characterId
                || $0.tamerName == characterId
        }
    }

    private func appearance(
        for characterId: String
    ) -> MonsterAppearanceData? {
        let normalizedId = characterId.lowercased()

        return appearances.first {
            $0.id == characterId
                || $0.imageName == characterId
                || $0.title.lowercased() == normalizedId
                || $0.imageName.lowercased()
                    == "mon_\(normalizedId)"
        }
    }

    // MARK: - Weighted pool selection

    private func weightedCandidate(
        from candidates: [PoolCandidate]
    ) -> PoolCandidate? {
        let validCandidates = candidates.filter {
            $0.weight > 0
        }

        let totalWeight = validCandidates.reduce(0) {
            $0 + $1.weight
        }

        guard totalWeight > 0 else {
            return nil
        }

        var roll = Int.random(in: 1...totalWeight)

        for candidate in validCandidates {
            roll -= candidate.weight

            if roll <= 0 {
                return candidate
            }
        }

        return validCandidates.last
    }

    private func nearestCandidates(
        to targetRarity: String,
        in candidates: [PoolCandidate]
    ) -> [PoolCandidate] {
        let targetRank = Self.rarityRank(targetRarity)

        let rankedCandidates = candidates.map {
            (
                candidate: $0,
                rank: Self.rarityRank($0.rarity)
            )
        }

        let equalOrHigher = rankedCandidates.filter {
            $0.rank >= targetRank
        }

        if let nearestHigherRank = equalOrHigher.map(\.rank).min() {
            return equalOrHigher
                .filter { $0.rank == nearestHigherRank }
                .map(\.candidate)
        }

        guard let highestAvailableRank =
            rankedCandidates.map(\.rank).max()
        else {
            return []
        }

        return rankedCandidates
            .filter { $0.rank == highestAvailableRank }
            .map(\.candidate)
    }

    // MARK: - Rarity roll

    private func resultRarity(
        for summon: SummonData,
        index: Int,
        count: Int
    ) -> String {
        let configuredRates = rates(for: summon)

        // Bei 10x ist der letzte Pull mindestens Rare.
        if count >= 10 && index == count - 1 {
            let guaranteedRates = configuredRates.filter {
                Self.rarityRank($0.rarity)
                    >= Self.rarityRank("rare")
            }

            return weightedRarity(
                from: guaranteedRates.isEmpty
                    ? configuredRates
                    : guaranteedRates
            )
        }

        return weightedRarity(from: configuredRates)
    }

    private func weightedRarity(
        from rates: [SummonRateData]
    ) -> String {
        let validRates = rates.filter {
            $0.weight > 0
        }

        let totalWeight = validRates.reduce(0) {
            $0 + $1.weight
        }

        guard totalWeight > 0 else {
            return "common"
        }

        var roll = Int.random(in: 1...totalWeight)

        for rate in validRates {
            roll -= rate.weight

            if roll <= 0 {
                return rate.rarity
            }
        }

        return validRates.last?.rarity ?? "common"
    }

    // MARK: - UI helpers

    func currencyName(_ currency: String) -> String {
        switch currency.lowercased() {
        case "crystal", "crystals":
            return "Kristalle"

        case "summon_ticket", "summon_tickets", "ticket", "tickets":
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

            guard
                let self,
                self.summonMessage == message
            else {
                return
            }

            self.summonMessage = nil
        }
    }

    private func rarityColor(
        _ rarity: String
    ) -> Color {
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

    // MARK: - Rarity helpers

    private static let defaultRates = [
        SummonRateData(
            rarity: "common",
            title: "Common",
            weight: 7000
        ),
        SummonRateData(
            rarity: "rare",
            title: "Rare",
            weight: 2200
        ),
        SummonRateData(
            rarity: "epic",
            title: "Epic",
            weight: 750
        ),
        SummonRateData(
            rarity: "legendary",
            title: "Legendär",
            weight: 50
        ),
    ]

    private static let supporterCategoryIds: Set<String> = [
        "montam",
        "tamer",
        "mega_supporter",
    ]

    private static func rarityRank(
        _ rarity: String
    ) -> Int {
        switch normalizedRarity(rarity) {
        case "common":
            return 0

        case "rare":
            return 1

        case "epic":
            return 2

        case "legendary":
            return 3

        default:
            return 0
        }
    }

    private static func normalizedRarity(
        _ rarity: String?
    ) -> String {
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

// MARK: - Internal pool types

private struct PoolCandidate {
    let character: PoolCharacter
    let characterId: String
    let rarity: String
    let weight: Int
}

private enum PoolCharacter {
    case monster(MonsterData)
    case monsterAppearance(MonsterAppearanceData)
    case tamer(TamerData)
}
