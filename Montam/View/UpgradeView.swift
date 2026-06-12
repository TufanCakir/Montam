//
//  UpgradeView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct UpgradeView: View {
    @ObservedObject var teamManager: TeamManager
    @ObservedObject private var medalManager = MontamMedalManager.shared
    @ObservedObject private var coinManager = MontamCoinsManager.shared

    @State private var config = UpgradeConfigLoader.load()

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(teamManager.ownedCharacters) { owned in
                        upgradeCard(owned)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background {
            MontamBackground()
        }
        .navigationTitle("Upgrade")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            config = UpgradeConfigLoader.load()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MONTAM UPGRADE")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Medals aus Events erhoehen Stars und Stats.")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
        }
    }

    private func upgradeCard(_ owned: OwnedCharacter) -> some View {
        let medalId =
            medalDefinition(for: owned.baseId)?.id ?? "\(owned.baseId)_medal"
        let medalIcon =
            medalDefinition(for: owned.baseId)?.icon ?? owned.base.sprite
        let cost = starCost(for: owned.stars)
        let medalAmount = medalManager.amount(for: medalId)
        let canUpgrade =
            cost != nil
            && medalAmount >= (cost?.medals ?? 0)
            && coinManager.montamCoins >= (cost?.montamCoins ?? 0)
            && !owned.isMaxStar

        return VStack(spacing: 10) {
            RemoteAssetImage(
                name: SkinInventoryManager.shared.activeImage(for: owned.base)
            )
            .scaledToFit()
            .frame(height: 90)

            Text(owned.base.name.uppercased())
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 8) {
                stat("ATK", owned.totalAttack)
                stat("HP", owned.totalHP)
            }

            MontamStarRow(stars: owned.stars, size: 13)

            HStack(spacing: 7) {
                RemoteAssetImage(name: medalIcon)
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text("\(medalAmount) / \(cost?.medals ?? 0)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(
                        canUpgrade
                            ? MontamPalette.gold
                            : MontamPalette.mutedText
                    )
            }

            Button {
                upgrade(owned, medalId: medalId, cost: cost)
            } label: {
                Text(owned.isMaxStar ? "MAX" : "STAR UP")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(
                        canUpgrade
                            ? MontamPalette.black : .white.opacity(0.45)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(
                        canUpgrade
                            ? MontamPalette.gold : MontamPalette.black
                    )
                    .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)
            .disabled(!canUpgrade)
        }
        .padding(12)
        .background(MontamPalette.panel)
        .overlay(
            MontamCutRectangle(cut: 16)
                .stroke(
                    canUpgrade
                        ? MontamPalette.gold : MontamPalette.blue,
                    lineWidth: 1.5
                )
        )
        .clipShape(MontamCutRectangle(cut: 16))
    }

    private func stat(_ title: String, _ value: Int) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
            Text("\(value)")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private func medalDefinition(for characterId: String)
        -> MontamMedalDefinition?
    {
        config.medalDefinitions.first { $0.characterId == characterId }
    }

    private func starCost(for star: Int) -> StarUpgradeCost? {
        config.starCosts.first { $0.fromStar == star }
    }

    private func upgrade(
        _ owned: OwnedCharacter,
        medalId: String,
        cost: StarUpgradeCost?
    ) {
        guard let cost else { return }
        guard medalManager.spend(cost.medals, medalId: medalId) else { return }
        if let montamCoins = cost.montamCoins, !coinManager.spend(montamCoins) {
            medalManager.add(cost.medals, medalId: medalId)
            return
        }
        teamManager.upgradeStars(for: owned)
    }
}

#Preview {
    UpgradeView(teamManager: TeamManager())
}
