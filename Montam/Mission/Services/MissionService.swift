//
//  MissionService.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftData

@MainActor
enum MissionService {
    static func missions() -> [MissionData] {
        JSONDataLoader.load("mission", as: [MissionData].self) ?? []
    }

    static func progress(save: GameSaveData?) -> [MissionProgress] {
        let missions = missions()
        let claimed = Set(save?.claimedMissionRewardIds ?? [])

        return missions.map { mission in
            let currentValue = value(for: mission.kind, save: save)
            let claimIndex = nextClaimIndex(
                mission: mission,
                currentValue: currentValue,
                claimed: claimed
            )
            let targetValue = targetValue(for: mission, claimIndex: claimIndex)

            return MissionProgress(
                mission: mission,
                claimIndex: claimIndex,
                currentValue: currentValue,
                targetValue: targetValue,
                isClaimed: claimed.contains(
                    claimId(for: mission, claimIndex: claimIndex)
                )
            )
        }
    }

    static func claim(
        progress: MissionProgress,
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        let claimId = claimId(
            for: progress.mission,
            claimIndex: progress.claimIndex
        )
        guard progress.canClaim,
            !save.claimedMissionRewardIds.contains(claimId)
        else {
            return
        }

        apply(rewards: progress.mission.rewards, to: save)
        save.claimedMissionRewardIds.append(claimId)
        try? modelContext.save()
    }

    static func claimAll(
        progressItems: [MissionProgress],
        saves: [GameSaveData],
        modelContext: ModelContext
    ) {
        let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        for progress in progressItems where progress.canClaim {
            let claimId = claimId(
                for: progress.mission,
                claimIndex: progress.claimIndex
            )
            guard !save.claimedMissionRewardIds.contains(claimId) else {
                continue
            }

            apply(rewards: progress.mission.rewards, to: save)
            save.claimedMissionRewardIds.append(claimId)
        }

        try? modelContext.save()
    }

    private static func nextClaimIndex(
        mission: MissionData,
        currentValue: Int,
        claimed: Set<String>
    ) -> Int {
        let completedClaimCount = max(
            claimed.filter { $0.hasPrefix("\(mission.id):") }.count,
            0
        )
        let maxClaims = mission.maxClaims ?? Int.max
        let nextIndex = min(completedClaimCount, max(maxClaims - 1, 0))

        guard mission.repeatStep != nil else {
            return 0
        }

        return currentValue >= targetValue(for: mission, claimIndex: nextIndex)
            ? nextIndex
            : completedClaimCount
    }

    private static func targetValue(
        for mission: MissionData,
        claimIndex: Int
    ) -> Int {
        mission.target + max(claimIndex, 0) * max(mission.repeatStep ?? 0, 0)
    }

    private static func value(
        for kind: MissionKind,
        save: GameSaveData?
    ) -> Int {
        switch kind {
        case .reachStage:
            return save?.currentStage ?? 1
        case .reachPlayerLevel:
            return save?.playerLevel ?? 1
        case .reachPower:
            return save?.playerPower ?? 0
        case .collectCoins:
            return save?.coins ?? 0
        case .collectCrystals:
            return save?.crystals ?? 0
        }
    }

    private static func apply(rewards: [RewardData], to save: GameSaveData) {
        for reward in rewards {
            save.changeCurrency(reward.resourceId, by: reward.amount)
        }
    }

    private static func claimId(
        for mission: MissionData,
        claimIndex: Int
    ) -> String {
        "\(mission.id):\(claimIndex)"
    }
}
