//
//  PlayerStatusBar.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct PlayerStatusBarState {
    let imageName: String
    let level: Int
    let power: Int
    let xp: Int
    let maxXP: Int
    let coins: Int
    let crystals: Int
    let bits: Int
}

struct PlayerStatusBar: View {
    let state: PlayerStatusBarState

    var body: some View {
        HStack(spacing: PlayerStatusBarMetrics.itemSpacing) {
            PlayerAvatar(imageName: state.imageName, level: state.level)

            PowerMeter(
                power: state.power,
                xp: state.xp,
                maxXP: state.maxXP,
                progress: progressValue
            )
            .layoutPriority(1)

            HStack(spacing: 7) {
                CurrencyPill(
                    iconId: "coin",
                    fallbackImage: "icon_coin",
                    amount: state.coins
                )

                CurrencyPill(
                    iconId: "crystal",
                    fallbackImage: "icon_crystal",
                    amount: state.crystals
                )

                CurrencyPill(
                    iconId: "bit",
                    fallbackImage: "icon_bit",
                    amount: state.bits
                )
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, PlayerStatusBarMetrics.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressValue: Double {
        let xp = Double(state.xp)
        let maxXP = Double(max(state.maxXP, 1))
        return min(max(xp / maxXP, 0), 1)
    }
}

private enum PlayerStatusBarMetrics {
    static let horizontalPadding: CGFloat = 10
    static let itemSpacing: CGFloat = 6

    static let avatarFrame = CGSize(width: 40, height: 44)
    static let avatarImageSize: CGFloat = 32
    static let avatarCornerRadius: CGFloat = 7

    static let meterMinWidth: CGFloat = 72
    static let meterMaxWidth: CGFloat = 92
    static let progressHeight: CGFloat = 4

    static let currencyWidth: CGFloat = 56
    static let currencyHeight: CGFloat = 28
    static let currencyIconSize: CGFloat = 17
    static let currencyCornerRadius: CGFloat = 6
}

private struct PlayerAvatar: View {
    let imageName: String
    let level: Int

    var body: some View {
        VStack(spacing: 2) {
            RemoteAssetImage(imageName: imageName)
                .scaledToFit()
                .padding(3)
                .frame(
                    width: PlayerStatusBarMetrics.avatarImageSize,
                    height: PlayerStatusBarMetrics.avatarImageSize
                )
                .background(Color.blue.opacity(0.30))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: PlayerStatusBarMetrics.avatarCornerRadius
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: PlayerStatusBarMetrics.avatarCornerRadius
                    )
                    .stroke(.white.opacity(0.25), lineWidth: 1)
                )

            Text("Lv. \(level)")
                .font(.system(size: 8, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(
            width: PlayerStatusBarMetrics.avatarFrame.width,
            height: PlayerStatusBarMetrics.avatarFrame.height
        )
    }
}

private struct PowerMeter: View {
    let power: Int
    let xp: Int
    let maxXP: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {

                Text(GameNumberFormatter.compact(power))
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            ProgressView(value: progress)
                .tint(.green)
                .background(Color.black.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(alignment: .center) {
                    Text(
                        "\(GameNumberFormatter.compact(xp))/\(GameNumberFormatter.compact(maxXP))"
                    )
                    .font(.system(size: 8, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                }
                .frame(height: PlayerStatusBarMetrics.progressHeight)
        }
        .frame(
            minWidth: PlayerStatusBarMetrics.meterMinWidth,
            maxWidth: PlayerStatusBarMetrics.meterMaxWidth,
            alignment: .leading
        )
    }
}

private struct CurrencyPill: View {
    let iconId: String
    let fallbackImage: String
    let amount: Int

    var body: some View {
        HStack(spacing: 6) {
            GameResourceIcon(id: iconId, fallbackImage: fallbackImage)
                .frame(
                    width: PlayerStatusBarMetrics.currencyIconSize,
                    height: PlayerStatusBarMetrics.currencyIconSize
                )

            Text(GameNumberFormatter.compact(amount))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(.horizontal, 5)
        .frame(
            width: PlayerStatusBarMetrics.currencyWidth,
            height: PlayerStatusBarMetrics.currencyHeight
        )
        .background(Color.blue.opacity(0.30))
        .clipShape(
            RoundedRectangle(
                cornerRadius: PlayerStatusBarMetrics.currencyCornerRadius
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: PlayerStatusBarMetrics.currencyCornerRadius
            )
            .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
}

#Preview {
    PlayerStatusBar(
        state: PlayerStatusBarState(
            imageName: "mon_kyron",
            level: 1,
            power: 0,
            xp: 0,
            maxXP: 100,
            coins: 0,
            crystals: 0,
            bits: 0
        )
    )
}
