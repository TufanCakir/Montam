//
//  MissionPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftData
import SwiftUI

struct MissionPanel: View {
    let onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @State private var progressItems: [MissionProgress] = []

    private var hasClaimableReward: Bool {
        progressItems.contains(where: \.canClaim)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if progressItems.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(progressItems) { item in
                            MissionCard(item: item) {
                                MissionService.claim(
                                    progress: item,
                                    saves: saves,
                                    modelContext: modelContext
                                )
                                reload()
                            }
                        }
                    }
                    .padding(14)
                }
                .frame(maxHeight: 480)
                .gamePanelBodyBackground()
            }
        }
        .gamePanelFrame()
        .onAppear(perform: reload)
    }

    private var header: some View {
        GamePanelHeader(title: "Missionen", onClose: onClose) {
            Button("Alle") {
                MissionService.claimAll(
                    progressItems: progressItems,
                    saves: saves,
                    modelContext: modelContext
                )
                reload()
            }
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(.black)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Color.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .buttonStyle(.plain)
            .opacity(hasClaimableReward ? 1 : 0.45)
            .disabled(!hasClaimableReward)
        }
    }

    private var emptyState: some View {
        GamePanelEmptyState(title: "Missionen werden vorbereitet.")
    }

    private func reload() {
        progressItems = MissionService.progress(save: saves.first)
    }
}

private struct MissionCard: View {
    let item: MissionProgress
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.mission.title)
                        .font(
                            .system(size: 19, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Text(item.mission.description)
                        .font(
                            .system(size: 13, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.cyan.opacity(0.88))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Button(action: onClaim) {
                    Text(item.isClaimed ? "OK" : "Holen")
                        .font(
                            .system(size: 13, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(item.canClaim ? .black : .white)
                        .frame(width: 58, height: 32)
                        .background(
                            item.canClaim
                                ? Color.yellow : Color.black.opacity(0.28)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!item.canClaim)
                .opacity(item.canClaim ? 1 : 0.55)
            }

            ProgressView(value: item.progress)
                .tint(item.canClaim ? .yellow : .green)
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .frame(height: 9)

            HStack {
                Text(
                    "\(min(item.currentValue, item.targetValue))/\(item.targetValue)"
                )
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.green)

                Spacer()

                rewardRow
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                item.canClaim ? .yellow.opacity(0.9) : .cyan.opacity(0.42),
                lineWidth: 1.5
            )
        )
    }

    private var rewardRow: some View {
        HStack(spacing: 8) {
            ForEach(item.mission.rewards) { reward in
                HStack(spacing: 3) {
                    GameResourceIcon(
                        id: GameCurrency.iconId(for: reward.resourceId),
                        fallbackImage: "icon_\(reward.resourceId)"
                    )
                    .frame(width: 17, height: 17)

                    Text("+\(reward.amount)")
                        .font(
                            .system(size: 12, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
