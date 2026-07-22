//
//  AppFlowView.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import SwiftData
import SwiftUI

struct AppFlowView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @State private var didTapStart = false
    @State private var didFinishOnboarding = false

    var body: some View {
        if !didTapStart {
            StartView {
                didTapStart = true
            } onDataDeleted: {
                resetToStart()
            }
        } else if didFinishOnboarding || saves.first?.didCompleteOnboarding == true {
            RootView {
                resetToStart()
            }
        } else {
            OnboardingView {
                didFinishOnboarding = true
            }
        }
    }

    private func resetToStart() {
        didTapStart = false
        didFinishOnboarding = false
    }
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]
    @State private var message: String?

    private let monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
    private let starterGift = JSONDataLoader.load("gift", as: [GiftData].self)?.first
    private let progression = JSONDataLoader.load("battleConfig", as: OnboardingProgressionData.self) ?? OnboardingProgressionData()

    var body: some View {
        VStack(spacing: 22) {
            Text("Wähle dein erstes Monster")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 2)

            Text("Du startest mit Level 1. Tamer sind Supporter und geben deinem Monster Boni.")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(monsters, id: \.id) { monster in
                    Button {
                        startGame(with: monster)
                    } label: {
                        VStack(spacing: 10) {
                            Image(monster.monsterName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)

                            Text(monster.name)
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)

                            Text("Lv. 1")
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(.blue.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.cyan.opacity(0.75), lineWidth: 2))
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

        let selectedMonster = ownedMonsters.first { $0.monsterId == monster.id } ?? OwnedMonsterData(monsterId: monster.id)
        selectedMonster.level = max(selectedMonster.level, 1)
        selectedMonster.isSelected = true

        if selectedMonster.modelContext == nil {
            modelContext.insert(selectedMonster)
        }

        if let firstTamer = tamers.first {
            for ownedTamer in ownedTamers {
                ownedTamer.isSelected = false
            }

            let support = ownedTamers.first { $0.tamerId == firstTamer.id } ?? OwnedTamerData(tamerId: firstTamer.id)
            support.level = max(support.level, 1)
            support.isSelected = true

            if support.modelContext == nil {
                modelContext.insert(support)
            }
        }

        let save = saves.first ?? GameSaveData()
        save.didCompleteOnboarding = true
        save.playerLevel = 1
        save.playerXP = 0
        save.playerMaxXP = progression.resolvedXPBase
        save.playerPower = starterPower(for: monster)
        save.coins = starterGift?.coins ?? save.coins
        save.crystals = starterGift?.crystals ?? save.crystals

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

struct MonsterSelectView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]

    private let monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Monster wechseln")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text("Auswahl gilt für den nächsten Kampf. Im laufenden Kampf wird nicht gewechselt.")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)

                ForEach(monsters, id: \.id) { monster in
                    let owned = ownedMonsters.first { $0.monsterId == monster.id }
                    SelectionRow(
                        imageName: monster.monsterName,
                        title: monster.name,
                        subtitle: owned.map { "Lv. \($0.level) · XP \($0.xp)" } ?? "Noch nicht besitzt",
                        isSelected: owned?.isSelected == true,
                        isEnabled: owned != nil
                    ) {
                        selectMonster(monster.id)
                    }
                }

                Text("Tamer Support")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 18)

                ForEach(tamers, id: \.id) { tamer in
                    let owned = ownedTamers.first { $0.tamerId == tamer.id }
                    SelectionRow(
                        imageName: tamer.tamerName,
                        title: tamer.name,
                        subtitle: owned.map { "Lv. \($0.level) · Support aktiv" } ?? "Noch nicht besitzt",
                        isSelected: owned?.isSelected == true,
                        isEnabled: owned != nil
                    ) {
                        selectTamer(tamer.id)
                    }
                }
            }
            .padding(24)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            AppScreenBackground()
        }
    }

    private func selectMonster(_ id: String) {
        for monster in ownedMonsters {
            monster.isSelected = monster.monsterId == id
        }

        try? modelContext.save()
    }

    private func selectTamer(_ id: String) {
        for tamer in ownedTamers {
            tamer.isSelected = tamer.tamerId == id
        }

        try? modelContext.save()
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

private struct SelectionRow: View {
    let imageName: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 74, height: 74)
                    .opacity(isEnabled ? 1 : 0.38)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(isEnabled ? .cyan : .gray)
                }

                Spacer()

                Text(isSelected ? "Aktiv" : "Wählen")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? .black : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isSelected ? .yellow : .blue)
                    .clipShape(Capsule())
                    .opacity(isEnabled ? 1 : 0.35)
            }
            .padding(12)
            .background(.blue.opacity(isSelected ? 0.68 : 0.36))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? .yellow : .cyan.opacity(0.45), lineWidth: 2))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
