//
//  StorySelectionView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct StorySelectionView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var config = GameConfigManager.shared.config
    @State private var selectedDifficultyId: String = "normal"

    private var difficulties: [BattleDifficulty] {
        config.battleDifficulties.isEmpty
            ? GameConfig.fallback.battleDifficulties
            : config.battleDifficulties
    }

    private var selectedDifficulty: BattleDifficulty {
        difficulties.first { $0.id == selectedDifficultyId }
            ?? difficulties[0]
    }

    var body: some View {
        VStack(spacing: 14) {
            difficultyBar

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(config.storyChapters) { chapter in
                        chapterCard(chapter)
                    }
                }
                .padding(18)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            config = GameConfigManager.shared.config
            selectedDifficultyId = difficulties.first?.id ?? "normal"
        }
    }

    private var difficultyBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(difficulties) { difficulty in
                    let selected = selectedDifficultyId == difficulty.id

                    Button {
                        selectedDifficultyId = difficulty.id
                    } label: {
                        Text(difficulty.title.uppercased())
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selected ? MontamPalette.black : .white
                            )
                            .padding(.horizontal, 16)
                            .frame(height: 38)
                            .background(
                                selected
                                    ? MontamPalette.gold
                                    : MontamPalette.panel
                            )
                            .clipShape(
                                MontamEvolutionShape()
                            )
                            .overlay(
                                MontamEvolutionShape()
                                    .stroke(
                                        selected
                                            ? MontamPalette.blue
                                            : MontamPalette.gold
                                                .opacity(0.45),
                                        lineWidth: 1.2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
        }
    }

    private func chapterCard(_ chapter: StoryChapter) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                RemoteAssetImage(name: chapter.icon)
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .background(MontamPalette.black.opacity(0.58))
                    .clipShape(MontamCutRectangle(cut: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text(chapter.title.uppercased())
                        .font(
                            .system(size: 17, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(chapter.description.uppercased())
                        .font(
                            .system(size: 10, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.mutedText)
                        .lineLimit(2)

                    Text(
                        "\(selectedDifficulty.title.uppercased())  HP x\(selectedDifficulty.enemyHpMultiplier, specifier: "%.1f")"
                    )
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)
                }

                Spacer(minLength: 0)
            }

            Text(chapter.storyText)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .lineLimit(3)

            rewardStrip(chapter.rewards)

            Button {
                appModel.navigateWithLoading {
                    appModel.startStoryBattle(
                        chapter: chapter,
                        difficulty: selectedDifficulty
                    )
                }
            } label: {
                Text("KAPITEL STARTEN")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(MontamPalette.gold)
                    .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamEvolutionShape())
        .overlay(
            MontamEvolutionShape()
                .stroke(MontamPalette.gold, lineWidth: 1.7)
        )
    }

    private func rewardStrip(_ rewards: EventRewards?) -> some View {
        HStack(spacing: 7) {
            rewardChip(
                "montamCoins",
                rewards?.montamCoins,
                icon: "icon_montam_coins"
            )
            rewardChip(
                "montamSaphirs",
                rewards?.montamSaphirs,
                icon: "icon_montam_saphir"
            )
            rewardChip(
                "montamRubys",
                rewards?.montamRubys,
                icon: "icon_montam_rubys"
            )
            rewardChip(
                "montamLiquid",
                rewards?.montamLiquid,
                icon: "icon_montam_liquid"
            )
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func rewardChip(_ title: String, _ value: Int?, icon: String)
        -> some View
    {
        if let value, value > 0 {
            MontamRewardChip(title: title, value: value, icon: icon)
        }
    }
}

#Preview {
    StorySelectionView()
        .environmentObject(AppModel())
}
