//
//  BattleSceneContainer.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SpriteKit
import SwiftUI

struct BattleSceneContainer: View {
    let scene: GameScene

    var body: some View {
        SpriteView(scene: scene)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    static func makeScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }

    static func setPaused(_ isPaused: Bool, scene: GameScene) {
        scene.isPaused = isPaused
    }
}
