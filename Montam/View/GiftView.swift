//
//  GiftView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct GiftView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var claimManager = GiftClaimManager.shared

    @State private var gifts: [Gift] = GiftLoader.load()

    private var availableGifts: [Gift] {
        gifts.filter { !claimManager.isClaimed($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if availableGifts.isEmpty {
                    emptyState
                } else {
                    ForEach(availableGifts) { gift in
                        giftRow(gift)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(MontamScreenBackground())
        .navigationTitle("Gifts")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            gifts = GiftLoader.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GIFT CENTER")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Remote Rewards aus gifts.json")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 78, height: 78)
                .opacity(0.72)

            Text("ALLE GIFTS GECLAIMT")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 90)
    }

    private func giftRow(_ gift: Gift) -> some View {
        Button {
            claim(gift)
        } label: {
            HStack(spacing: 16) {
                RemoteAssetImage(name: gift.icon ?? "montam_icon")
                    .scaledToFit()
                    .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text((gift.title ?? gift.type.rawValue).uppercased())
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(giftSubtitle(gift))
                        .font(
                            .system(size: 11, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.mutedText)
                        .lineLimit(2)
                }

                Spacer()

                Text("CLAIM")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(MontamPalette.gold)
                    .clipShape(MontamEvolutionShape())
            }
            .padding(14)
            .background(MontamPalette.panel)
            .overlay(
                MontamEvolutionShape()
                    .stroke(
                        gift.type == .montamContainers || gift.type == .montamShards
                            ? MontamPalette.blue : MontamPalette.gold,
                        lineWidth: 1.7
                    )
            )
            .clipShape(MontamEvolutionShape())
        }
        .buttonStyle(.plain)
    }

    private func giftSubtitle(_ gift: Gift) -> String {
        if let note = gift.note {
            return note
        }
        if gift.type == .montam, let characterId = gift.characterId {
            return "MONTAM: \(characterId)"
        }
        if gift.type == .skin, let skinId = gift.skinId {
            return "SKIN: \(skinId)"
        }
        return "+\(gift.amount ?? 0) \(gift.type.rawValue.uppercased())"
    }

    private func claim(_ gift: Gift) {
        RewardApplier.apply(
            type: gift.type,
            amount: gift.amount,
            characterId: gift.characterId,
            eggId: gift.eggId,
            skinId: gift.skinId,
            teamManager: appModel.teamManager
        )
        claimManager.claim(gift.id)
    }
}

#Preview {
    GiftView()
        .environmentObject(AppModel())
}
