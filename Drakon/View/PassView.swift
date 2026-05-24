//
//  PassView.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import SwiftUI

struct PassView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var progress = PassProgressManager.shared

    @State private var passes = PassLoader.loadAll()
    @State private var selectedPassId: String?
    @State private var infoPass: PassConfig?

    private var selectedPass: PassConfig? {
        passes.first { $0.id == selectedPassId } ?? passes.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                passSelector

                if let config = selectedPass {
                    ForEach(config.tiers) { tier in
                        tierRow(tier, config: config)
                    }
                } else {
                    Text("Keine Pass JSON geladen")
                        .font(
                            .system(size: 15, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(DrakonBladePalette.mutedText)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(DrakonScreenBackground())
        .navigationTitle("Passes")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            passes = PassLoader.loadAll()
            selectedPassId = selectedPassId ?? passes.first?.id
        }
        .sheet(item: $infoPass) { pass in
            passInfoSheet(pass)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteAssetImage(
                name: selectedPass?.backgroundImage
                    ?? selectedPass?.icon
                    ?? "drakon_icon"
            )
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 146)
            .opacity(0.36)
            .clipped()

            LinearGradient(
                colors: [
                    DrakonBladePalette.black.opacity(0.20),
                    DrakonBladePalette.black.opacity(0.88),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(spacing: 14) {
                RemoteAssetImage(name: selectedPass?.icon ?? "drakon_icon")
                    .scaledToFit()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 5) {
                    Text((selectedPass?.title ?? "PASSES").uppercased())
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("PROGRESS \(progress.points(for: selectedPass?.id ?? ""))")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(DrakonBladePalette.gold)
                }

                Spacer()

                if let selectedPass {
                    Button {
                        infoPass = selectedPass
                    } label: {
                        RemoteAssetImage(name: "icon_info")
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .padding(8)
                            .background(DrakonBladePalette.gold)
                            .clipShape(DrakonCutRectangle(cut: 9))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
        }
        .frame(height: 146)
        .background(DrakonBladePalette.panel)
        .clipShape(DrakonBladeShape(pointDepth: 32, slant: 14))
        .overlay(
            DrakonBladeShape(pointDepth: 32, slant: 14)
                .stroke(DrakonBladePalette.gold, lineWidth: 1.8)
        )
    }

    private var passSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(passes) { pass in
                    let selected = selectedPass?.id == pass.id

                    Button {
                        selectedPassId = pass.id
                    } label: {
                        HStack(spacing: 7) {
                            RemoteAssetImage(name: pass.icon)
                                .scaledToFit()
                                .frame(width: 24, height: 24)

                            Text(pass.title.uppercased())
                                .font(
                                    .system(
                                        size: 10,
                                        weight: .black,
                                        design: .rounded
                                    )
                                )
                        }
                        .foregroundStyle(
                            selected ? DrakonBladePalette.black : .white
                        )
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(
                            selected
                                ? DrakonBladePalette.gold
                                : DrakonBladePalette.panel
                        )
                        .clipShape(DrakonBladeShape(pointDepth: 14, slant: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func tierRow(_ tier: PassTier, config: PassConfig) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIER \(tier.tier)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(DrakonBladePalette.gold)

            HStack(spacing: 12) {
                rewardBox(
                    tier.free,
                    tier: tier.tier,
                    lane: "free",
                    config: config
                )
                rewardBox(
                    tier.premium,
                    tier: tier.tier,
                    lane: "premium",
                    config: config
                )
            }
        }
        .padding(14)
        .background(DrakonBladePalette.panel)
        .overlay(
            DrakonCutRectangle(cut: 16)
                .stroke(DrakonBladePalette.blue, lineWidth: 1.4)
        )
        .clipShape(DrakonCutRectangle(cut: 16))
    }

    private func rewardBox(
        _ reward: PassReward?,
        tier: Int,
        lane: String,
        config: PassConfig
    ) -> some View {
        let claimed = progress.isClaimed(
            passId: config.id,
            tier: tier,
            lane: lane
        )
        let canClaim = progress.canClaim(
            passId: config.id,
            tier: tier,
            pointsPerTier: config.pointsPerTier,
            lane: lane
        )

        return Button {
            guard let reward, canClaim else { return }
            RewardApplier.apply(
                type: reward.type,
                amount: reward.amount,
                characterId: reward.characterId,
                eggId: reward.eggId,
                skinId: reward.skinId,
                teamManager: appModel.teamManager
            )
            progress.claim(passId: config.id, tier: tier, lane: lane)
        } label: {
            VStack(spacing: 7) {
                Text(lane.uppercased())
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(
                        lane == "premium"
                            ? DrakonBladePalette.gold : DrakonBladePalette.blue
                    )

                Text(reward?.title.uppercased() ?? "EMPTY")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(claimed ? "CLAIMED" : (canClaim ? "CLAIM" : "LOCKED"))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(
                        canClaim
                            ? DrakonBladePalette.black
                            : DrakonBladePalette.mutedText
                    )
                    .frame(height: 26)
                    .frame(maxWidth: .infinity)
                    .background(
                        canClaim
                            ? DrakonBladePalette.gold : DrakonBladePalette.black
                    )
                    .clipShape(DrakonBladeShape(pointDepth: 12, slant: 7))
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .frame(height: 118)
            .background(DrakonBladePalette.panelLight)
            .clipShape(DrakonCutRectangle(cut: 12))
        }
        .buttonStyle(.plain)
    }

    private func passInfoSheet(_ pass: PassConfig) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteAssetImage(name: pass.backgroundImage ?? pass.icon)
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(DrakonBladeShape(pointDepth: 34, slant: 14))

                HStack(spacing: 12) {
                    RemoteAssetImage(name: pass.icon)
                        .scaledToFit()
                        .frame(width: 54, height: 54)

                    VStack(alignment: .leading, spacing: 5) {
                        Text((pass.infoTitle ?? pass.title).uppercased())
                            .font(
                                .system(
                                    size: 22,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)

                        Text(pass.currencyTitle.uppercased())
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(DrakonBladePalette.gold)
                    }
                }

                Text(
                    pass.infoBody
                        ?? "Sammle Pass XP durch Battles und claim deine Rewards pro Tier."
                )
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(DrakonBladePalette.mutedText)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(pass.infoTasks ?? defaultTasks(for: pass), id: \.self) {
                        task in
                        HStack(alignment: .top, spacing: 10) {
                            RemoteAssetImage(name: "icon_info")
                                .scaledToFit()
                                .frame(width: 20, height: 20)

                            Text(task)
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .black,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(14)
                .background(DrakonBladePalette.panel)
                .clipShape(DrakonCutRectangle(cut: 14))
            }
            .padding(22)
        }
        .background(DrakonScreenBackground())
    }

    private func defaultTasks(for pass: PassConfig) -> [String] {
        [
            "Kaempfe in Story oder Events, um \(pass.currencyTitle) zu sammeln.",
            "Alle \(pass.pointsPerTier) Punkte wird ein neuer Tier freigeschaltet.",
            "Free Rewards sind direkt claimbar. Premium Rewards sind fuer spaetere Premium-Pass Freischaltung vorbereitet.",
        ]
    }
}

#Preview {
    PassView()
        .environmentObject(AppModel())
}
