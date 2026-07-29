//
//  GameView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct GameView: View {
    let store: GameStore

    @State private var stageState = BattleStageState.empty
    @State private var didConfigureScene = false
    @State private var scene = BattleSceneContainer.makeScene()
    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let progression =
        JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
        ?? GameProgressionData()

    var body: some View {
        ZStack(alignment: .top) {
            BattleSceneContainer(scene: scene)

            BattleStageOverlay(state: stageState)
                .padding(.top, 112)
        }
        .onAppear {
            configureScene()
        }
            .onChange(of: runtimeSelectionSignature) { _, _ in
                configureScene()
            }
            .onDisappear {
                scene.clearCallbacks()
            }
    }

    private var runtimeSelectionSignature: String {
        let monsters = store.ownedMonsters
            .filter(\.isSelected)
            .map {
                "\($0.monsterId):\($0.level):\($0.xp):\($0.equippedImageName ?? "")"
            }
            .sorted()
            .joined(separator: "|")
        let supporters = store.ownedSupporters
            .filter(\.isSelected)
            .map {
                "\($0.bannerId):\($0.characterId):\($0.imageName):\($0.level):\($0.isMonster)"
            }
            .sorted()
            .joined(separator: "|")
        return "\(store.currentStage)#\(monsters)#\(supporters)"
    }

    private func configureScene() {
        guard !didConfigureScene else {
            scene.updateProgressStage(store.currentStage)
            scene.updateRuntimeSelection(
                selectedMonsters: store.runtimeSelectedMonsters(),
                selectedTamers: store.runtimeSelectedTamers(),
                selectedSupporters: store.runtimeSelectedSupporters()
            )
            return
        }

        didConfigureScene = true
        scene.onStageChanged = { state in
            stageState = state
        }

        scene.onStageCompleted = { nextStage in
            store.updateStage(nextStage)
        }

        scene.updateProgressStage(store.currentStage)

        scene.onBattleWon = { [weak scene] reward in
            store.applyBattleReward(
                reward,
                monsterCatalog: monsterCatalog,
                progression: progression
            )
            scene?.updateRuntimeSelection(
                selectedMonsters: store.runtimeSelectedMonsters(),
                selectedTamers: store.runtimeSelectedTamers(),
                selectedSupporters: store.runtimeSelectedSupporters()
            )
        }

        scene.configure(
            selectedMonsters: store.runtimeSelectedMonsters(),
            selectedTamers: store.runtimeSelectedTamers(),
            selectedSupporters: store.runtimeSelectedSupporters()
        )
    }

}

#Preview {
    RootView()
}
