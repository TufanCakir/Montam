import Foundation
import SwiftData

@MainActor
enum AppSettingsService {
    static let musicEnabledKey = "settings.musicEnabled"

    static func deleteUserData(modelContext: ModelContext) {
        do {
            for save in try modelContext.fetch(FetchDescriptor<GameSaveData>()) {
                modelContext.delete(save)
            }

            for monster in try modelContext.fetch(FetchDescriptor<OwnedMonsterData>()) {
                modelContext.delete(monster)
            }

            for tamer in try modelContext.fetch(FetchDescriptor<OwnedTamerData>()) {
                modelContext.delete(tamer)
            }

            try modelContext.save()
        } catch {
            assertionFailure("Could not delete user data: \(error)")
        }
    }

    static func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        removeTemporaryFiles()
    }

    private static func removeTemporaryFiles() {
        let fileManager = FileManager.default
        let temporaryDirectory = fileManager.temporaryDirectory

        guard let items = try? fileManager.contentsOfDirectory(
            at: temporaryDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return
        }

        for item in items {
            try? fileManager.removeItem(at: item)
        }
    }
}
