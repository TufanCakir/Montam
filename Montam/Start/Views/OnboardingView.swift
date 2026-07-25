//
//  OnboardingView.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @State private var message: String?

    private let monsters =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let starterGift = JSONDataLoader.load("gift", as: [GiftData].self)?
        .first
    private let progression =
        JSONDataLoader.load("battleConfig", as: OnboardingProgressionData.self)
        ?? OnboardingProgressionData()

    var body: some View {
        VStack(spacing: 22) {
            Text("Wähle dein erstes Monster")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 2)

            Text(
                "Du startest mit Level 1. Tamer sind Supporter und geben deinem Monster Boni."
            )
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.cyan)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {
                ForEach(monsters, id: \.id) { monster in
                    Button {
                        startGame(with: monster)
                    } label: {
                        VStack(spacing: 10) {
                            RemoteAssetImage(imageName: monster.monsterName)
                                .scaledToFit()
                                .frame(height: 150)

                            Text(monster.name)
                                .font(
                                    .system(
                                        size: 22,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.white)

                            Text("Lv. 1")
                                .font(
                                    .system(
                                        size: 16,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.green)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(
                                .cyan.opacity(0.75),
                                lineWidth: 2
                            )
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)

            Spacer()
        }
        .padding(.top, 84)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            AppScreenBackground()
        }
        .overlay {
            if let message {
                Text(message)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.74))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 32)
            }
        }
        .ignoresSafeArea()
    }

    private func startGame(with monster: MonsterData) {
        for ownedMonster in ownedMonsters {
            ownedMonster.isSelected = false
        }

        let selectedMonster =
            ownedMonsters.first { $0.monsterId == monster.id }
            ?? OwnedMonsterData(monsterId: monster.id)
        selectedMonster.level = max(selectedMonster.level, 1)
        selectedMonster.isSelected = true
        selectedMonster.equippedImageName =
            selectedMonster.equippedImageName ?? monster.monsterName

        if selectedMonster.modelContext == nil {
            modelContext.insert(selectedMonster)
        }

        let save = saves.first ?? GameSaveData()
        save.didCompleteOnboarding = true
        save.playerLevel = 1
        save.playerXP = 0
        save.playerMaxXP = progression.resolvedXPBase
        save.playerPower = starterPower(for: monster)
        starterGift?.rewards.forEach { GameCurrency.apply($0, to: save) }

        if save.modelContext == nil {
            modelContext.insert(save)
        }

        do {
            try modelContext.save()
            onComplete()
        } catch {
            message = "Spielstand konnte nicht gespeichert werden."
        }
    }

    private func starterPower(for monster: MonsterData) -> Int {
        let hpScore = (monster.hp ?? 0) / 10
        return hpScore + (monster.attack ?? 0) + (monster.defense ?? 0)
    }
}

private struct OnboardingProgressionData: Decodable {
    let xpBase: Int?

    init(xpBase: Int? = nil) {
        self.xpBase = xpBase
    }

    var resolvedXPBase: Int {
        max(xpBase ?? 100, 1)
    }
}

#Preview {
    OnboardingView {}
}
