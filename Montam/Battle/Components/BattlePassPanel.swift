//
//  BattlePassPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 26.07.26.
//

import SwiftUI

struct MontamPassData: Codable {
    let rewards: [BattlePassRewardDefinition]
}

struct BattlePassRewardDefinition: Codable, Identifiable {
    let id: String
    let requiredPoints: Int
    let title: String
    let titleKey: String?
    let coins: Int
    let bits: Int
    let summonTickets: Int
    let xp: Int
}

enum BattlePassCatalog {
    static func loadRewards() -> [BattlePassRewardDefinition] {
        let rewards =
            JSONDataLoader.load("montamPass", as: MontamPassData.self)?
            .rewards
            ?? fallbackRewards

        return rewards.sorted { $0.requiredPoints < $1.requiredPoints }
    }

    private static let fallbackRewards: [BattlePassRewardDefinition] = [
        BattlePassRewardDefinition(
            id: "pass_001",
            requiredPoints: 12,
            title: "Start-Bonus",
            titleKey: nil,
            coins: 500,
            bits: 10,
            summonTickets: 1,
            xp: 50
        ),
        BattlePassRewardDefinition(
            id: "pass_002",
            requiredPoints: 30,
            title: "Tamer-Vorrat",
            titleKey: nil,
            coins: 1_250,
            bits: 20,
            summonTickets: 2,
            xp: 90
        ),
        BattlePassRewardDefinition(
            id: "pass_003",
            requiredPoints: 50,
            title: "Beschwörer-Paket",
            titleKey: nil,
            coins: 2_000,
            bits: 35,
            summonTickets: 4,
            xp: 140
        ),
        BattlePassRewardDefinition(
            id: "pass_004",
            requiredPoints: 90,
            title: "Champion-Bonus",
            titleKey: nil,
            coins: 4_000,
            bits: 60,
            summonTickets: 7,
            xp: 250
        ),
    ]
}

struct BattlePassPanel: View {
    let store: GameStore
    let onClose: () -> Void

    @State private var message: String?
    private let rewards = BattlePassCatalog.loadRewards()

    private var points: Int {
        store.montamPassPoints
    }

    private var claimedRewardIds: Set<String> {
        store.claimedBattlePassRewardIds
    }

    private var nextReward: BattlePassRewardDefinition? {
        rewards.first {
            !claimedRewardIds.contains($0.id)
        }
    }

    private var progressTarget: Int {
        max(nextReward?.requiredPoints ?? points, 1)
    }

    private var previousRewardPoints: Int {
        guard let nextReward,
            let index = rewards.firstIndex(where: { $0.id == nextReward.id }),
            index > 0
        else {
            return 0
        }

        return rewards[index - 1].requiredPoints
    }

    private var currentTierProgress: CGFloat {
        guard let nextReward else {
            return 1
        }

        let required = max(nextReward.requiredPoints - previousRewardPoints, 1)
        let earned = min(max(points - previousRewardPoints, 0), required)
        return CGFloat(earned) / CGFloat(required)
    }

    private var claimedCount: Int {
        rewards.filter { claimedRewardIds.contains($0.id) }.count
    }

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 12) {
                header

                if store.hasEventPass {
                    passProgress
                    rewardList
                } else {
                    lockedContent
                }

                if let message {
                    Text(message)
                        .font(
                            .system(size: 14, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
            }
            .padding(16)
            .frame(maxWidth: 390)
            .battlePassPanelSurface()
            .padding(.horizontal, 18)

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.black.opacity(0.22))
                    .frame(width: 62, height: 46)
                GameResourceIcon(id: "pass", fallbackImage: nil)
                    .frame(width: 34, height: 34)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(AppLocalizationService.text("shop.montamPass"))
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(
                    store.hasEventPass
                        ? AppLocalizationService.text("pass.points", points)
                        : AppLocalizationService.text("pass.unlockInShop")
                )
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
            }

            Spacer(minLength: 0)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.cyan)
                    .frame(width: 32, height: 32)
                    .background(.black.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
    }

    private var passProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        nextReward.map(rewardTitle)
                            ?? AppLocalizationService.text("pass.completed")
                    )
                    .font(
                        .system(size: 17, weight: .black, design: .rounded)
                    )
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                    Text(
                        AppLocalizationService.text(
                            "pass.rewardCount",
                            claimedCount,
                            rewards.count
                        )
                    )
                    .font(
                        .system(size: 12, weight: .heavy, design: .rounded)
                    )
                    .foregroundStyle(.white.opacity(0.72))
                }

                Spacer()

                Text("\(min(points, progressTarget))/\(progressTarget)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.cyan)
            }

            BattlePassProgressBar(progress: currentTierProgress)

            if let nextReward {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppLocalizationService.text("pass.nextReward"))
                        .font(
                            .system(size: 12, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.cyan)

                    RewardIconStrip(reward: nextReward)
                }
                .padding(10)
                .background(.black.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(.blue.opacity(0.26))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var rewardList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(rewards) { reward in
                    BattlePassRewardRow(
                        reward: reward,
                        points: points,
                        isClaimed: claimedRewardIds.contains(reward.id),
                        onClaim: {
                            claim(reward)
                        }
                    )
                }
            }
        }
        .frame(maxHeight: 360)
    }

    private var lockedContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(.yellow)

            Text(AppLocalizationService.text("pass.notPurchased"))
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(
                AppLocalizationService.text("pass.lockedMessage")
            )
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(.cyan)
            .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.blue.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func claim(_ reward: BattlePassRewardDefinition) {
        if store.claimBattlePassReward(reward) {
            message = AppLocalizationService.text("pass.claimed")
        } else {
            message = AppLocalizationService.text("pass.notReady")
        }
    }

    private func rewardTitle(_ reward: BattlePassRewardDefinition) -> String {
        if let titleKey = reward.titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return reward.title
    }
}

private struct BattlePassRewardRow: View {
    let reward: BattlePassRewardDefinition
    let points: Int
    let isClaimed: Bool
    let onClaim: () -> Void

    private var canClaim: Bool {
        points >= reward.requiredPoints && !isClaimed
    }

    var body: some View {
        HStack(spacing: 10) {
            rewardStateBadge

            VStack(alignment: .leading, spacing: 5) {
                Text(rewardTitle)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    AppLocalizationService.text(
                        "pass.points",
                        reward.requiredPoints
                    )
                )
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)

                RewardIconStrip(reward: reward)
            }

            Spacer(minLength: 0)

            Button(action: onClaim) {
                Text(
                    isClaimed
                        ? AppLocalizationService.text("common.ok")
                        : AppLocalizationService.text("gift.claim")
                )
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(canClaim ? .black : .white.opacity(0.7))
                .frame(width: 78, height: 34)
                .background(canClaim ? .yellow : .black.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .disabled(!canClaim)
        }
        .padding(12)
        .background(.blue.opacity(isClaimed ? 0.18 : 0.34))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    canClaim ? .yellow.opacity(0.9) : .cyan.opacity(0.25),
                    lineWidth: 1
                )
        )
    }

    private var rewardStateBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isClaimed
                        ? Color.green.opacity(0.82)
                        : canClaim
                            ? Color.yellow.opacity(0.95)
                            : Color.black.opacity(0.28)
                )
                .frame(width: 36, height: 48)

            Image(
                systemName: isClaimed
                    ? "checkmark"
                    : canClaim
                        ? "gift.fill"
                        : "lock.fill"
            )
            .font(.system(size: 16, weight: .black))
            .foregroundStyle(isClaimed || canClaim ? .black : .cyan)
        }
    }

    private var rewardTitle: String {
        if let titleKey = reward.titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return reward.title
    }
}

private struct BattlePassProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.black.opacity(0.35))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
            .overlay(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { index in
                        Circle()
                            .fill(
                                progress >= CGFloat(index + 1) / 6
                                    ? .white
                                    : .white.opacity(0.28)
                            )
                            .frame(width: 5, height: 5)

                        if index < 5 {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .frame(height: 13)
    }
}

private struct RewardIconStrip: View {
    let reward: BattlePassRewardDefinition

    var body: some View {
        HStack(spacing: 6) {
            ForEach(rewardItems) { item in
                HStack(spacing: 4) {
                    GameResourceIcon(id: item.resourceId, fallbackImage: nil)
                        .frame(width: 18, height: 18)

                    Text("+\(GameNumberFormatter.compact(item.amount))")
                        .font(
                            .system(size: 11, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .padding(.horizontal, 6)
                .frame(height: 28)
                .background(.black.opacity(0.24))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
    }

    private var rewardItems: [RewardDisplayItem] {
        [
            RewardDisplayItem(resourceId: "coins", amount: reward.coins),
            RewardDisplayItem(resourceId: "bits", amount: reward.bits),
            RewardDisplayItem(
                resourceId: "summon_ticket",
                amount: reward.summonTickets
            ),
            RewardDisplayItem(resourceId: "exp", amount: reward.xp),
        ]
        .filter { $0.amount > 0 }
    }
}

private struct RewardDisplayItem: Identifiable {
    let resourceId: String
    let amount: Int

    var id: String {
        resourceId
    }
}

extension View {
    fileprivate func battlePassPanelSurface() -> some View {
        background(
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.05, blue: 0.22),
                    Color(red: 0.0, green: 0.18, blue: 0.42),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.cyan.opacity(0.7), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.5), radius: 18, y: 8)
    }
}
