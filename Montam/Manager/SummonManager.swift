//
//  SummonManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class SummonManager: ObservableObject {

    static let shared = SummonManager()

    // MARK: - Published

    @Published private(set) var characters: [Character] = []
    @Published private(set) var banners: [SummonBanner] = []
    @Published private(set) var categories: [SummonCategory] = []

    // MARK: - Private

    private var characterMap: [String: Character] = [:]

    // MARK: - Init

    init() {
        loadAll()
    }

    // MARK: - Loading

    private func loadAll() {
        loadCharacters()
        loadSummonData()
    }

    private func loadCharacters() {
        do {
            characters = try JSONLoader.load("characters")
            characterMap = Dictionary(
                uniqueKeysWithValues:
                    characters.map { ($0.id, $0) }
            )
            print("✅ Characters loaded:", characters.count)
        } catch {
            print("❌ Character load failed:", error)
        }
    }

    private func loadSummonData() {
        do {
            let root: SummonRoot = try JSONLoader.load("summons")
            banners = root.banners
            categories = root.categories
            print("🎴 Banners loaded:", banners.count)
        } catch {
            print("❌ Summon load failed:", error)
        }
    }

    func startDate(for bannerId: String) -> Date {
        let key = "banner_start_\(bannerId)"

        if let saved = UserDefaults.standard.object(forKey: key) as? Date {

            let end = saved.addingTimeInterval(7 * 86400)

            if Date() > end {
                let newStart = Date()
                UserDefaults.standard.set(newStart, forKey: key)
                return newStart
            }

            return saved
        }

        let now = Date()
        UserDefaults.standard.set(now, forKey: key)
        return now
    }

    func timeRemaining(for bannerId: String) -> String {
        let start = startDate(for: bannerId)
        let end = start.addingTimeInterval(7 * 86400)

        let remaining = end.timeIntervalSince(Date())

        if remaining <= 0 {
            return "Ended"
        }

        let days = Int(remaining) / 86400
        let hours = (Int(remaining) % 86400) / 3600

        return "\(days)d \(hours)h"
    }

    // MARK: - Category Filter
    func banners(for categoryId: String) -> [SummonBanner] {

        let categoryBanners = banners.filter { $0.category == categoryId }

        // Nur für limited markieren wir den aktiven Banner
        if categoryId != "limited" {
            return categoryBanners
        }

        guard !categoryBanners.isEmpty else { return [] }

        // 👉 ALLE Banner zurückgeben (NICHT nur 1!)
        return categoryBanners
    }
}

extension SummonManager {

    func totalPulls(for bannerId: String) -> Int {
        UserDefaults.standard.integer(forKey: "pulls_\(bannerId)")
    }

    func addPull(for bannerId: String, amount: Int = 1) {
        let key = "pulls_\(bannerId)"
        let current = totalPulls(for: bannerId)
        UserDefaults.standard.set(current + amount, forKey: key)

        objectWillChange.send()  // 🔥 WICHTIG für UI Update
    }

    func canSummon(_ banner: SummonBanner) -> Bool {
        guard banner.maxSummons > 0 else { return true }
        return totalPulls(for: banner.id) < banner.maxSummons
    }
}

// MARK: - Pool Handling

extension SummonManager {

    private func poolEntries(
        for banner: SummonBanner,
        applyLimit: Bool
    ) -> [SummonPoolEntry] {

        // ❌ KEIN prefix mehr!
        return banner.pool
    }
}

// MARK: - Rates (Info Screen)

extension SummonManager {

    /// Shows FULL pool in info screen
    func rates(for bannerId: String) -> [CharacterRate] {

        guard let banner = banners.first(where: { $0.id == bannerId }) else {
            return []
        }

        let weightedEntries: [(Character, Double, Bool)] = poolEntries(
            for: banner,
            applyLimit: false
        )
        .compactMap { entry in
            guard let character = characterMap[entry.characterId] else {
                return nil
            }

            let baseRate = character.rarity.summonRate
            let weight = entry.rateUp ? baseRate * 2.0 : baseRate
            return (character, weight, entry.rateUp)
        }

        let total = weightedEntries.reduce(0.0) { $0 + $1.1 }
        guard total > 0 else { return [] }

        return
            weightedEntries
            .map { character, weight, isRateUp in
                CharacterRate(
                    character: character,
                    rate: weight / total,
                    isRateUp: isRateUp
                )
            }
            .sorted { $0.rate > $1.rate }
    }
}

// MARK: - Summon Logic

extension SummonManager {

    /// Uses poolLimit for actual pulls
    func summon(from bannerId: String) -> Character? {
        guard let banner = banners.first(where: { $0.id == bannerId }) else {
            return nil
        }

        let entries = poolEntries(for: banner, applyLimit: true)
        guard !entries.isEmpty else { return nil }

        return weightedSummon(from: entries, banner: banner)  // ⭐ reuse!
    }
}

extension SummonManager {

    // MARK: - Mastered Summon (Pity + Step-Up)
    func smartSummon(from banner: SummonBanner) -> Character? {
        // ⭐ 1. PITY CHECK
        if let pity = banner.pity, pity.enabled {
            let pulls = PityManager.shared.pulls(for: banner.id)
            if pulls + 1 >= pity.requiredPulls {
                PityManager.shared.reset(for: banner.id)
                if let entry = pity.guaranteedPool.randomElement() {
                    return self.characterMap[entry.characterId]
                }
            }
        }

        // ⭐ 2. STEP-UP CHECK
        let pool: [SummonPoolEntry]
        if let stepUp = banner.stepUp, stepUp.enabled {
            let step = currentStep(for: banner.id, maxSteps: stepUp.steps.count)
            let stepData = stepUp.steps.first { $0.step == step }

            // 🎁 Guaranteed step reward
            if let guaranteed = stepData?.guaranteed {
                advanceStep(for: banner.id, maxSteps: stepUp.steps.count)
                return self.characterMap[guaranteed.characterId]
            }

            pool = stepData?.pool ?? banner.pool
            advanceStep(for: banner.id, maxSteps: stepUp.steps.count)
        } else {
            pool = banner.pool
        }

        // ⭐ 3. Normal pull
        let character = weightedSummon(from: pool, banner: banner)

        // ⭐ 4. Increase pity
        PityManager.shared.addPull(for: banner.id)

        return character
    }

    // MARK: - Step Info (für UI)
    func currentStepData(for banner: SummonBanner) -> StepUpStep? {
        guard let stepUp = banner.stepUp, stepUp.enabled else { return nil }

        let step = currentStep(for: banner.id, maxSteps: stepUp.steps.count)  // ✅
        return stepUp.steps.first { $0.step == step }
    }

    // MARK: - Weighted Summon
    private func weightedSummon(
        from entries: [SummonPoolEntry],
        banner: SummonBanner
    ) -> Character? {

        let weighted: [(Character, Double)] = entries.compactMap { entry in
            guard let character = characterMap[entry.characterId] else {
                return nil
            }

            var rate = character.rarity.summonRate

            // ⭐ RateUp boost
            if entry.rateUp == true {
                rate *= 2.0
            }

            return (character, rate)
        }

        let total = weighted.reduce(0.0) { $0 + $1.1 }
        guard total > 0 else { return nil }

        let roll = Double.random(in: 0..<total)

        var cumulative = 0.0

        for (character, rate) in weighted {
            cumulative += rate
            if roll <= cumulative {
                return character
            }
        }

        return weighted.last?.0
    }

    // MARK: - Step Progress
    private func currentStep(for bannerId: String, maxSteps: Int) -> Int {
        let step = UserDefaults.standard.integer(forKey: "step_\(bannerId)")
        let normalized = (step == 0) ? 1 : step
        return Swift.min(maxSteps, Swift.max(1, normalized))
    }

    private func advanceStep(for bannerId: String, maxSteps: Int) {
        let key = "step_\(bannerId)"
        let current = UserDefaults.standard.integer(forKey: key)
        let next = current + 1
        if next > maxSteps {
            UserDefaults.standard.set(1, forKey: key)  // 🔁 Reset to Step 1
        } else {
            UserDefaults.standard.set(next, forKey: key)
        }
    }
}

// MARK: - View Models

struct CharacterRate: Identifiable {
    let id = UUID()
    let character: Character
    let rate: Double
    let isRateUp: Bool
}
