//
//  ViewModel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation
import Observation

@Observable
class ViewModel {
    private(set) var backgrounds: [BackgroundData] = []
    private(set) var enemies: [EnemyData] = []
    private(set) var monsters: [MonsterData] = []
    private(set) var tamers: [TamerData] = []
    private(set) var loadingError: String?

    var selectedBackground: BackgroundData? {
        backgrounds.first
    }

    init() {
        loadData()
    }

    private func loadData() {
        backgrounds =
            JSONDataLoader.load("background", as: [BackgroundData].self) ?? []
        enemies = JSONDataLoader.load("enemy", as: [EnemyData].self) ?? []
        monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
        tamers = JSONDataLoader.load("tamer", as: [TamerData].self) ?? []
    }
}
