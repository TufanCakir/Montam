//
//  GameConfigManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

final class GameConfigManager {
    static let shared = GameConfigManager()

    let config: GameConfig

    private init() {
        do {
            config = try JSONLoader.load("game_config")
        } catch {
            print("Game config load failed:", error)
            config = .fallback
        }
    }
}
