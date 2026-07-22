//
//  ViewModel.swift
//  Monster Transorfmieren
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
        backgrounds = loadJSON("background", as: [BackgroundData].self) ?? []
        enemies = loadJSON("enemy", as: [EnemyData].self) ?? []
        monsters = loadJSON("monster", as: [MonsterData].self) ?? []
        tamers = loadJSON("tamer", as: [TamerData].self) ?? []
    }

    private func loadJSON<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            loadingError = "Could not find \(fileName).json in bundle."
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            loadingError = "Could not decode \(fileName).json: \(error.localizedDescription)"
            return nil
        }
    }
}
