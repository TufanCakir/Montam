//
//  DailyLoginPopupView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct DailyLoginPopupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = DailyRewardManager.shared

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 86, height: 86)

                VStack(spacing: 5) {
                    Text("DAILY LOGIN")
                        .font(
                            .system(size: 24, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text("TAG \(manager.currentDay)")
                        .font(
                            .system(size: 13, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.gold)
                }

                rewardPanel(
                    title: "HEUTE",
                    reward: manager.todaysReward,
                    tint: MontamPalette.gold
                )

                rewardPanel(
                    title: "MORGEN",
                    reward: manager.nextReward,
                    tint: MontamPalette.blue
                )

                Button {
                    manager.claim()
                    dismiss()
                } label: {
                    Text("ABHOLEN")
                        .font(
                            .system(size: 17, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(MontamPalette.gold)
                        .clipShape(
                            MontamEggShape()
                        )
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("SPATER")
                        .font(
                            .system(size: 12, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.mutedText)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MontamScreenBackground())
    }

    private func rewardPanel(
        title: String,
        reward: DailyReward?,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(tint)

            if let reward {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(rewardItems(for: reward)) { item in
                        rewardTile(item, tint: tint)
                    }
                }
            } else {
                Text("Keine Belohnung konfiguriert")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MontamPalette.panel)
        .overlay(
            MontamCutRectangle(cut: 18)
                .stroke(tint, lineWidth: 1.6)
        )
        .clipShape(MontamCutRectangle(cut: 18))
    }

    private func rewardTile(_ item: DailyRewardItem, tint: Color) -> some View {
        HStack(spacing: 8) {
            RemoteAssetImage(name: item.icon)
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)

                Text("+\(item.amount)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(MontamPalette.black.opacity(0.72))
        .clipShape(MontamEggShape())
        .overlay(
            MontamEggShape()
                .stroke(tint.opacity(0.9), lineWidth: 1)
        )
    }

    private func rewardItems(for reward: DailyReward) -> [DailyRewardItem] {
        [
            DailyRewardItem.make(
                title: "montamCoins",
                amount: reward.montamCoins,
                icon: "icon_montam_coins"
            ),
            DailyRewardItem.make(
                title: "montamSaphirs",
                amount: reward.montamSaphirs,
                icon: "icon_montam_saphir"
            ),
            DailyRewardItem.make(
                title: "montamRubys",
                amount: reward.montamRubys,
                icon: "icon_montam_rubys"
            ),
            DailyRewardItem.make(
                title: "montamLiquid",
                amount: reward.montamLiquid,
                icon: "icon_montam_liquid"
            ),
            DailyRewardItem.make(
                title: "montamShards",
                amount: reward.montamShards,
                icon: "icon_montam_shards"
            ),
            DailyRewardItem.make(
                title: "montamContainers",
                amount: reward.montamContainers,
                icon: "icon_montam_shards"
            ),
            DailyRewardItem.make(
                title: "EXP",
                amount: reward.exp,
                icon: "montam_icon"
            ),
        ]
        .compactMap { $0 }
    }
}

private struct DailyRewardItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: Int
    let icon: String

    static func make(
        title: String,
        amount: Int?,
        icon: String
    ) -> DailyRewardItem? {
        guard let amount, amount > 0 else { return nil }
        return DailyRewardItem(title: title, amount: amount, icon: icon)
    }
}

#Preview {
    DailyLoginPopupView()
}
