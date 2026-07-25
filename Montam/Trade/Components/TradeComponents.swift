//
//  TradeComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct TradeWalletPanel: View {
    let save: GameSaveData?

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 8
        ) {
            TradeWalletTile(
                iconId: "coin",
                title: "Coins",
                amount: save?.coins ?? 0
            )
            TradeWalletTile(
                iconId: "crystal",
                title: "Kristalle",
                amount: save?.crystals ?? 0
            )
            TradeWalletTile(
                iconId: "summon_ticket",
                title: "Tickets",
                amount: save?.summonTickets ?? 0
            )
            TradeWalletTile(
                iconId: "bit",
                title: "Bits",
                amount: save?.bits ?? 0
            )
        }
    }
}

struct TradeSection: View {
    let title: String
    let offers: [TradeOfferData]
    let canTrade: (TradeOfferData) -> Bool
    let onTrade: (TradeOfferData) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            ForEach(offers) { offer in
                TradeOfferRow(
                    offer: offer,
                    isEnabled: canTrade(offer)
                ) {
                    onTrade(offer)
                }
            }
        }
    }
}

struct TradeToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 32)
    }
}

struct TradeEmptyState: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.cyan)
            Text("Vorbereitung läuft")
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("Neue Tauschangebote erscheinen bald.")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TradeBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

private struct TradeOfferRow: View {
    let offer: TradeOfferData
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                TradeCurrencyBadge(
                    currency: offer.rewardCurrency,
                    amount: offer.rewardAmount
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title)
                        .font(
                            .system(size: 17, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if let subtitle = offer.subtitle {
                        Text(subtitle)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                    }
                }

                Spacer()

                HStack(spacing: 5) {
                    GameResourceIcon(
                        id: GameCurrency.iconId(for: offer.costCurrency),
                        fallbackImage: nil
                    )
                    .frame(width: 20, height: 20)
                    Text(GameNumberFormatter.compact(offer.costAmount))
                        .font(
                            .system(size: 14, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(isEnabled ? .white : .gray)
                }
                .padding(.horizontal, 8)
                .frame(height: 30)
                .background(Color.blue.opacity(isEnabled ? 0.34 : 0.18))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(isEnabled ? 0.34 : 0.18))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isEnabled ? .cyan.opacity(0.55) : .gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .opacity(isEnabled ? 1 : 0.65)
        }
        .buttonStyle(.plain)
    }
}

private struct TradeCurrencyBadge: View {
    let currency: String
    let amount: Int

    var body: some View {
        VStack(spacing: 3) {
            GameResourceIcon(
                id: GameCurrency.iconId(for: currency),
                fallbackImage: nil
            )
            .frame(width: 34, height: 34)
            Text("+\(GameNumberFormatter.compact(amount))")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(.yellow)
                .lineLimit(1)
        }
        .frame(width: 58, height: 58)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct TradeWalletTile: View {
    let iconId: String
    let title: String
    let amount: Int

    var body: some View {
        HStack(spacing: 8) {
            GameResourceIcon(id: iconId, fallbackImage: nil)
                .frame(width: 26, height: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
                Text(GameNumberFormatter.compact(amount))
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
