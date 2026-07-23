//
//  GameView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit
import SwiftData
import SwiftUI

struct GameView: View {
    let isPaused: Bool

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]
    @State private var stageState = BattleStageState.empty
    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let progression =
        JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
        ?? GameProgressionData()

    private let scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        ZStack(alignment: .top) {
            SpriteView(scene: scene)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            BattleStageOverlay(state: stageState)
                .padding(.top, 112)
        }
        .onAppear {
            configureScene()
        }
        .onChange(of: isPaused) { _, isPaused in
            scene.isPaused = isPaused
        }
        .onDisappear {
            scene.isPaused = true
        }
    }

    private func configureScene() {
        scene.onStageChanged = { state in
            stageState = state
        }

        scene.onStageCompleted = { nextStage in
            let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

            if save.modelContext == nil {
                modelContext.insert(save)
            }

            save.currentStage = nextStage
        }

        scene.updateProgressStage(saves.first?.currentStage ?? 1)

        scene.onBattleWon = { reward in
            let save = saves.first ?? GameSaveData(didCompleteOnboarding: true)

            if save.modelContext == nil {
                modelContext.insert(save)
            }

            for monster in ownedMonsters where monster.isSelected {
                monster.xp += reward.xp
                levelUpIfNeeded(monster)
            }

            save.coins += reward.coins
            save.crystals += reward.crystals
            refreshSavedPlayerStats(save: save)
            scene.updateRuntimeSelection(
                selectedMonsters: runtimeSelectedMonsters(),
                selectedTamers: runtimeSelectedTamers()
            )

            try? modelContext.save()
        }

        scene.configure(
            selectedMonsters: runtimeSelectedMonsters(),
            selectedTamers: runtimeSelectedTamers()
        )
    }

    private func runtimeSelectedMonsters() -> [RuntimeOwnedMonster] {
        ownedMonsters
            .filter(\.isSelected)
            .map {
                RuntimeOwnedMonster(
                    monsterId: $0.monsterId,
                    level: $0.level,
                    xp: $0.xp,
                    imageName: $0.equippedImageName
                )
            }
    }

    private func runtimeSelectedTamers() -> [RuntimeOwnedTamer] {
        ownedTamers
            .filter(\.isSelected)
            .map {
                RuntimeOwnedTamer(
                    tamerId: $0.tamerId,
                    level: $0.level,
                    xp: $0.xp
                )
            }
    }

    private func levelUpIfNeeded(_ monster: OwnedMonsterData) {
        while monster.level < progression.resolvedMaxLevel
            && monster.xp >= xpNeeded(for: monster.level)
        {
            monster.xp -= xpNeeded(for: monster.level)
            monster.level += 1
        }

        if monster.level >= progression.resolvedMaxLevel {
            monster.level = progression.resolvedMaxLevel
            monster.xp = min(
                monster.xp,
                xpNeeded(for: progression.resolvedMaxLevel)
            )
        }
    }

    private func xpNeeded(for level: Int) -> Int {
        GameProgressionCalculator.xpNeeded(for: level, progression: progression)
    }

    private func refreshSavedPlayerStats(save: GameSaveData) {
        let selected = ownedMonsters.filter(\.isSelected)
        save.playerLevel = selected.map(\.level).max() ?? save.playerLevel
        save.playerXP = selected.first?.xp ?? save.playerXP
        save.playerMaxXP = xpNeeded(for: save.playerLevel)
        save.playerPower = selected.reduce(0) { total, owned in
            guard
                let base = monsterCatalog.first(where: {
                    $0.id == owned.monsterId
                })
            else {
                return total
            }

            return total
                + GameProgressionCalculator.power(for: base, level: owned.level)
        }
    }
}

#Preview {
    GameView(isPaused: false)
}
