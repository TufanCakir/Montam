//
//  GiftBoxPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct GiftBoxPanel: View {
    let onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]

    private var gifts: [GiftData] {
        GiftBoxService.availableGifts(save: saves.first)
    }

    var body: some View {
        VStack(spacing: 0) {
            panelHeader

            if gifts.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        GiftActionButton(title: "Alles abholen", color: .yellow)
                        {
                            GiftBoxService.claimAll(
                                gifts: gifts,
                                saves: saves,
                                modelContext: modelContext
                            )
                        }

                        GiftActionButton(title: "Leeren", color: .red) {
                            GiftBoxService.clearGiftBox(
                                saves: saves,
                                modelContext: modelContext
                            )
                        }
                    }

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(gifts) { gift in
                                GiftCard(gift: gift) {
                                    GiftBoxService.claim(
                                        gift: gift,
                                        saves: saves,
                                        modelContext: modelContext
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 430)
                }
                .padding(16)
                .background(Color(red: 0.04, green: 0.16, blue: 0.34))
            }
        }
        .frame(width: 352)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                .cyan.opacity(0.9),
                lineWidth: 3
            )
        )
    }

    private var panelHeader: some View {
        HStack {
            Text("Geschenke")
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

    private var emptyState: some View {
        Text("Keine Geschenke vorhanden.")
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.cyan)
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.04, green: 0.16, blue: 0.34))
    }
}

private struct GiftCard: View {
    let gift: GiftData
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(gift.title)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            if let message = gift.message {
                Text(message)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
            }

            HStack(spacing: 8) {
                GiftReward(iconId: "coins", amount: gift.coins)
                GiftReward(iconId: "crystals", amount: gift.crystals)
                GiftReward(iconId: "bits", amount: gift.bits ?? 0)
                GiftReward(
                    iconId: "summon_ticket",
                    amount: gift.summonTickets ?? 0
                )
            }

            GiftActionButton(title: "Abholen", color: .cyan, action: onClaim)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
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

private struct GiftReward: View {
    let iconId: String
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            GameResourceIcon(id: iconId, fallbackImage: nil)
                .frame(width: 20, height: 20)
            Text(GameNumberFormatter.compact(amount))
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 7)
        .frame(height: 28)
        .background(.blue.opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct GiftActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(color == .yellow ? .black : .white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(color.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(
                        .black.opacity(0.7),
                        lineWidth: 2
                    )
                )
        }
        .buttonStyle(.plain)
    }
}
