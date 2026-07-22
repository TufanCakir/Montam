//
//  MontamApp.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

@main
struct MontamApp: App {
    init() {
        UserDefaults.standard.register(defaults: [
            AppSettingsService.musicEnabledKey: true
        ])
    }

    var body: some Scene {
        WindowGroup {
            AppFlowView()
        }
        .modelContainer(for: [
            GameSaveData.self,
            OwnedMonsterData.self,
            OwnedTamerData.self,
        ])
    }
}
