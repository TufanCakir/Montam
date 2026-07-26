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
            coins: 500,
            bits: 10,
            summonTickets: 1,
            xp: 50
        ),
        BattlePassRewardDefinition(
            id: "pass_002",
            requiredPoints: 30,
            title: "Tamer-Vorrat",
            coins: 1_250,
            bits: 20,
            summonTickets: 2,
            xp: 90
        ),
        BattlePassRewardDefinition(
            id: "pass_003",
            requiredPoints: 50,
            title: "Beschwörer-Paket",
            coins: 2_000,
            bits: 35,
            summonTickets: 4,
            xp: 140
        ),
        BattlePassRewardDefinition(
            id: "pass_004",
            requiredPoints: 90,
            title: "Champion-Bonus",
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

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 14) {
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
            .frame(maxWidth: 360)
            .rootPassPanelSurface()
            .padding(.horizontal, 18)

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.purple.gradient)
                    .frame(width: 58, height: 42)
                Image(systemName: "ticket.fill")
                    .font(.system(size: 25, weight: .black))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Montam Pass")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(
                    store.hasEventPass
                        ? "\(points) Montam Points" : "Im Shop freischalten"
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(nextReward?.title ?? "Pass abgeschlossen")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(min(points, progressTarget))/\(progressTarget)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.cyan)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.black.opacity(0.35))
                    Capsule()
                        .fill(.cyan)
                        .frame(
                            width: proxy.size.width
                                * min(
                                    CGFloat(points) / CGFloat(progressTarget),
                                    1
                                )
                        )
                }
            }
            .frame(height: 10)
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

            Text("Pass nicht gekauft")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(
                "Kaufe den Event-Pass im Shop. Montam-Points sammelst du weiter im Kampf."
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
            message = "Belohnung abgeholt."
        } else {
            message = "Noch nicht bereit."
        }
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
            VStack(alignment: .leading, spacing: 5) {
                Text(reward.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("\(reward.requiredPoints) Montam Points")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)

                Text(rewardSummary)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }

            Spacer(minLength: 0)

            Button(action: onClaim) {
                Text(isClaimed ? "OK" : "Abholen")
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

    private var rewardSummary: String {
        var parts: [String] = []
        if reward.coins > 0 {
            parts.append("+\(reward.coins) Coins")
        }
        if reward.bits > 0 {
            parts.append("+\(reward.bits) Bits")
        }
        if reward.summonTickets > 0 {
            parts.append("+\(reward.summonTickets) Tickets")
        }
        if reward.xp > 0 {
            parts.append("+\(reward.xp) XP")
        }
        return parts.joined(separator: "  ")
    }
}

extension View {
    fileprivate func rootPassPanelSurface() -> some View {
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
