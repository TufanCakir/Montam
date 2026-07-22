//
//  GameView.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit
import SwiftData
import SwiftUI

struct GameView: View {

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]
    private let monsterCatalog = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let progression = JSONDataLoader.load("battleConfig", as: GameProgressionData.self) ?? GameProgressionData()

    private let scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                configureScene()
            }
    }

    private func configureScene() {
        scene.onBattleWon = { earnedXP in
            for monster in ownedMonsters where monster.isSelected {
                monster.xp += earnedXP
                levelUpIfNeeded(monster)
            }

            refreshSavedPlayerStats()
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
            .map { RuntimeOwnedMonster(monsterId: $0.monsterId, level: $0.level, xp: $0.xp) }
    }

    private func runtimeSelectedTamers() -> [RuntimeOwnedTamer] {
        ownedTamers
            .filter(\.isSelected)
            .map { RuntimeOwnedTamer(tamerId: $0.tamerId, level: $0.level, xp: $0.xp) }
    }

    private func levelUpIfNeeded(_ monster: OwnedMonsterData) {
        while monster.level < progression.resolvedMaxLevel && monster.xp >= xpNeeded(for: monster.level) {
            monster.xp -= xpNeeded(for: monster.level)
            monster.level += 1
        }

        if monster.level >= progression.resolvedMaxLevel {
            monster.level = progression.resolvedMaxLevel
            monster.xp = min(monster.xp, xpNeeded(for: progression.resolvedMaxLevel))
        }
    }

    private func xpNeeded(for level: Int) -> Int {
        GameProgressionCalculator.xpNeeded(for: level, progression: progression)
    }

    private func refreshSavedPlayerStats() {
        guard let save = saves.first else {
            return
        }

        let selected = ownedMonsters.filter(\.isSelected)
        save.playerLevel = selected.map(\.level).max() ?? save.playerLevel
        save.playerXP = selected.first?.xp ?? save.playerXP
        save.playerMaxXP = xpNeeded(for: save.playerLevel)
        save.playerPower = selected.reduce(0) { total, owned in
            guard let base = monsterCatalog.first(where: { $0.id == owned.monsterId }) else {
                return total
            }

            return total + GameProgressionCalculator.power(for: base, level: owned.level)
        }
    }
}

#Preview {
    GameView()
}
