//
//  DailyLoginPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct DailyLoginPanel: View {
    let onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @State private var reward: DailyLoginData?
    @State private var rewards: [DailyLoginData] = []
    @State private var didClaim = false

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            VStack(spacing: 16) {
                DailyDayStrip(
                    rewards: rewards,
                    currentDay: currentDay,
                    didClaimToday: reward == nil
                )

                if let reward {
                    Button {
                        DailyLoginService.claim(
                            reward: reward,
                            saves: saves,
                            modelContext: modelContext
                        )
                        didClaim = true
                        self.reward = nil
                        rewards = DailyLoginService.rewards()
                    } label: {
                        DailyRewardCard(reward: reward)
                    }
                    .buttonStyle(.plain)
                } else {
                    DailyEmptyState(didClaim: didClaim)
                }
            }
            .padding(20)
            .gamePanelBodyBackground()
        }
        .gamePanelFrame(width: 344)
        .onAppear {
            rewards = DailyLoginService.rewards()
            reward = DailyLoginService.availableReward(saves: saves)
        }
    }

    private var currentDay: Int {
        reward?.day ?? saves.first?.dailyLoginDay ?? 1
    }

    private var panelHeader: some View {
        GamePanelHeader(title: "Daily Login", onClose: onClose)
    }
}

private struct DailyDayStrip: View {
    let rewards: [DailyLoginData]
    let currentDay: Int
    let didClaimToday: Bool

    var body: some View {
        if rewards.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(rewards) { reward in
                        DailyDayCell(
                            reward: reward,
                            status: status(for: reward.day)
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private func status(for day: Int) -> DailyDayStatus {
        if day < currentDay || (day == currentDay && didClaimToday) {
            return .claimed
        }

        if day == currentDay {
            return .today
        }

        return .locked
    }
}

private enum DailyDayStatus {
    case claimed
    case today
    case locked
}

private struct DailyDayCell: View {
    let reward: DailyLoginData
    let status: DailyDayStatus

    var body: some View {
        VStack(spacing: 6) {
            Text(AppLocalizationService.text("daily.day", reward.day))
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(titleColor)
                .lineLimit(1)

            GameResourceIcon(id: rewardIconId, fallbackImage: nil)
                .frame(width: 24, height: 24)

            Text(GameNumberFormatter.compact(rewardAmount))
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(width: 66, height: 82)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(
                borderColor,
                lineWidth: 1.4
            )
        )
        .opacity(status == .locked ? 0.55 : 1)
    }

    private var rewardIconId: String {
        reward.primaryReward.map { GameCurrency.iconId(for: $0.resourceId) }
            ?? "reward"
    }

    private var rewardAmount: Int {
        reward.primaryReward?.amount ?? 0
    }

    private var titleColor: Color {
        switch status {
        case .claimed: .green
        case .today: .yellow
        case .locked: .cyan
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .claimed: .green.opacity(0.22)
        case .today: .yellow.opacity(0.24)
        case .locked: .black.opacity(0.24)
        }
    }

    private var borderColor: Color {
        switch status {
        case .claimed: .green.opacity(0.7)
        case .today: .yellow.opacity(0.9)
        case .locked: .cyan.opacity(0.35)
        }
    }
}

private struct DailyRewardCard: View {
    let reward: DailyLoginData

    var body: some View {
        VStack(spacing: 14) {
            Text(AppLocalizationService.text("daily.day", reward.day))
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            ForEach(reward.rewards.filter { $0.amount > 0 }) { item in
                DailyRewardRow(reward: item)
            }

            Text(AppLocalizationService.text("daily.tapToClaim"))
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                .cyan.opacity(0.5),
                lineWidth: 1
            )
        )
    }
}

private struct DailyEmptyState: View {
    let didClaim: Bool

    var body: some View {
        Text(didClaim ? "Belohnung abgeholt." : "Heute bereits abgeholt.")
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.cyan)
            .multilineTextAlignment(.center)
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.24))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct DailyRewardRow: View {
    let reward: RewardData

    var body: some View {
        HStack(spacing: 10) {
            GameResourceIcon(
                id: GameCurrency.iconId(for: reward.resourceId),
                fallbackImage: nil
            )
            .frame(width: 28, height: 28)

            Text(GameNumberFormatter.compact(reward.amount))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
    }
}
