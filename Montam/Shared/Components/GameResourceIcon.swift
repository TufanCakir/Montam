//
//  GameResourceIcon.swift
//  Montam
//
//  Created by Tufan Cakir on 24.07.26.
//

import SwiftUI

struct GameResourceIcon: View {
    let id: String
    let fallbackImage: String?

    var body: some View {
        if let imageName {
            RemoteAssetImage(imageName: imageName)
                .scaledToFit()
        } else {
            Image(systemName: fallbackSystemName)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.cyan)
        }
    }

    private var imageName: String? {
        let normalizedId = GameCurrency.iconId(for: id)
        return GameVisualCatalog.imageName(for: id)
            ?? GameVisualCatalog.imageName(for: normalizedId)
            ?? nonEmpty(fallbackImage)
    }

    private var fallbackSystemName: String {
        "questionmark.circle.fill"
    }

    private func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else {
            return nil
        }

        return value
    }
}

enum GameVisualCatalog {
    private static let lock = NSLock()
    private static var cachedResourcesById: [String: GameVisualResourceData]?

    static func imageName(for id: String) -> String? {
        resource(id: id)?.imageName
    }

    static func invalidate() {
        lock.lock()
        cachedResourcesById = nil
        lock.unlock()
    }

    private static func resource(id: String) -> GameVisualResourceData? {
        resourcesById[id]
    }

    private static var resourcesById: [String: GameVisualResourceData] {
        lock.lock()
        defer { lock.unlock() }

        if let cachedResourcesById {
            return cachedResourcesById
        }

        let resources =
            JSONDataLoader.load("gameVisual", as: GameVisualCatalogData.self)?
            .resources ?? []
        let resourcesById = Dictionary(
            uniqueKeysWithValues: resources.map {
                ($0.id, $0)
            }
        )
        cachedResourcesById = resourcesById
        return resourcesById
    }
}
