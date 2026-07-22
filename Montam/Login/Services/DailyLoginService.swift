import Foundation
import SwiftData

@MainActor
enum DailyLoginService {
    static func rewards() -> [DailyLoginData] {
        (JSONDataLoader.load("daily", as: [DailyLoginData].self) ?? [])
            .sorted { $0.day < $1.day }
    }

    static func availableReward(saves: [GameSaveData]) -> DailyLoginData? {
        guard !didClaimToday(save: saves.first) else {
            return nil
        }

        let rewards = rewards()
        guard !rewards.isEmpty else {
            return nil
        }

        let nextDay = (saves.first?.dailyLoginDay ?? 0) + 1
        return rewards.first(where: { $0.day == nextDay }) ?? rewards.first
    }

    static func didClaimToday(save: GameSaveData?) -> Bool {
        guard let lastDailyClaimDate = save?.lastDailyClaimDate else {
            return false
        }

        return Calendar.current.isDateInToday(lastDailyClaimDate)
    }

    static func claim(
        reward: DailyLoginData,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        save.coins += reward.coins
        save.crystals += reward.crystals
        save.bits += reward.bits ?? 0
        save.summonTickets += reward.summonTickets ?? 0
        save.dailyLoginDay = reward.day
        save.lastDailyClaimDate = .now
        try? modelContext.save()
    }
}
