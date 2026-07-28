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
    private let modelContainer: ModelContainer

    init() {
        UserDefaults.standard.register(defaults: [
            AppSettingsService.musicEnabledKey: true,
            AppLocalizationService.languageKey:
                AppLocalizationService.fallbackLanguage.rawValue,
        ])

        modelContainer = Self.makeModelContainer()
    }

    var body: some Scene {
        WindowGroup {
            AppFlowView()
        }
        .modelContainer(modelContainer)
    }

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            GameSaveData.self,
            OwnedMonsterData.self,
            OwnedTamerData.self,
            OwnedSupporterData.self,
        ])

        let storeURL =
            applicationSupportDirectory
            .appending(path: "default.store")
        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("SwiftData store could not be created: \(error)")
        }
    }

    private static var applicationSupportDirectory: URL {
        let directory = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]

        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        return directory
    }
}
