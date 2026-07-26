//
//  GameView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct GameView: View {
    let isPaused: Bool
    let store: GameStore

    @State private var stageState = BattleStageState.empty
    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let progression =
        JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
        ?? GameProgressionData()

    private let scene = BattleSceneContainer.makeScene()

    var body: some View {
        ZStack(alignment: .top) {
            BattleSceneContainer(scene: scene)

            BattleStageOverlay(state: stageState)
                .padding(.top, 112)
        }
        .onAppear {
            configureScene()
        }
        .onChange(of: isPaused) { _, isPaused in
            BattleSceneContainer.setPaused(isPaused, scene: scene)
        }
        .onDisappear {
            BattleSceneContainer.setPaused(true, scene: scene)
        }
    }

    private func configureScene() {
        scene.onStageChanged = { state in
            stageState = state
        }

        scene.onStageCompleted = { nextStage in
            store.updateStage(nextStage)
        }

        scene.updateProgressStage(store.currentStage)

        scene.onBattleWon = { reward in
            store.applyBattleReward(
                reward,
                monsterCatalog: monsterCatalog,
                progression: progression
            )
            scene.updateRuntimeSelection(
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
