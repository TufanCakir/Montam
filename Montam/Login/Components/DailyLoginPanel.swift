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
    @State private var didClaim = false

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            VStack(spacing: 16) {
                if let reward {
                    Button {
                        DailyLoginService.claim(
                            reward: reward,
                            saves: saves,
                            modelContext: modelContext
                        )
                        didClaim = true
                        self.reward = nil
                    } label: {
                        DailyRewardCard(reward: reward)
                    }
                    .buttonStyle(.plain)
                } else {
                    DailyEmptyState(didClaim: didClaim)
                }
            }
            .padding(20)
            .background(Color(red: 0.04, green: 0.16, blue: 0.34))
        }
        .frame(width: 344)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                .cyan.opacity(0.9),
                lineWidth: 3
            )
        )
        .onAppear {
            reward = DailyLoginService.availableReward(saves: saves)
        }
    }

    private var panelHeader: some View {
        HStack {
            Text("Daily Login")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .background(
            LinearGradient(
                colors: [.blue, .cyan.opacity(0.78)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

private struct DailyRewardCard: View {
    let reward: DailyLoginData

    var body: some View {
        VStack(spacing: 14) {
            Text("Tag \(reward.day)")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            RewardRow(iconId: "coins", amount: reward.coins)
            RewardRow(iconId: "crystals", amount: reward.crystals)
            RewardRow(iconId: "bits", amount: reward.bits ?? 0)
            RewardRow(
                iconId: "summon_ticket",
                amount: reward.summonTickets ?? 0
            )

            Text("Zum Abholen tippen")
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

private struct RewardRow: View {
    let iconId: String
    let amount: Int

    var body: some View {
        HStack(spacing: 10) {
            GameResourceIcon(id: iconId, fallbackImage: nil)
                .frame(width: 28, height: 28)
            Text(GameNumberFormatter.compact(amount))
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
    }
}
