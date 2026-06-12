//
//  EventVictoryView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct EventVictoryView: View {
    let result: EventVictoryResult
    let onContinue: () -> Void

    private var rewardIcons: EventRewardIconConfig {
        GameConfigManager.shared.config.eventUI?.rewardIcons ?? .fallback
    }

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            RemoteAssetImage(name: result.icon)
                .scaledToFit()
                .frame(width: 132, height: 132)

            Text("VICTORY")
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            Text(result.title.uppercased())
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                MontamRewardLine(
                    title: "montamCoins",
                    value: result.montamCoins,
                    icon: rewardIcons.montamCoins
                )
                MontamRewardLine(
                    title: "montamRubys",
                    value: result.montamRubys,
                    icon: rewardIcons.montamRubys
                )
                MontamRewardLine(
                    title: "montamContainers",
                    value: result.montamContainers,
                    icon: rewardIcons.montamContainers
                )
                MontamRewardLine(
                    title: "montamLiquid",
                    value: result.montamLiquid,
                    icon: rewardIcons.montamLiquid
                )
                ForEach(result.eggRewards) { reward in
                    let egg = EggConfigLoader.load().eggs.first {
                        $0.id == reward.eggId
                    }
                    MontamRewardLine(
                        title: (egg?.title ?? reward.eggId).uppercased(),
                        value: reward.amount,
                        icon: egg?.eggImage ?? "egg_feral_cryon"
                    )
                }
                if let medalId = result.medalId {
                    MontamRewardLine(
                        title: (result.medalTitle ?? medalId).uppercased(),
                        value: result.medals,
                        icon: result.medalIcon ?? "montam_icon"
                    )
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(MontamPalette.panel)
            .overlay(
                MontamCutRectangle(cut: 18)
                    .stroke(MontamPalette.blue, lineWidth: 1.8)
            )
            .clipShape(MontamCutRectangle(cut: 18))

            Button(action: onContinue) {
                Text("ZURUCK ZUM MENU")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(MontamPalette.gold)
                    .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            MontamBackground()
        }
    }
}
