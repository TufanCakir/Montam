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
        nonEmpty(resource?.imageName) ?? nonEmpty(fallbackImage)
    }

    private var resource: GameVisualResourceData? {
        GameVisualCatalog.shared.resource(id: id)
            ?? GameVisualCatalog.shared.resource(id: GameCurrency.iconId(for: id))
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

private struct GameVisualCatalog {
    static let shared = GameVisualCatalog()

    private let resources: [GameVisualResourceData]

    init() {
        guard
            let url = Bundle.main.url(
                forResource: "gameVisual",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(
                GameVisualCatalogData.self,
                from: data
            )
        else {
            resources = []
            return
        }

        resources = catalog.resources
    }

    func resource(id: String) -> GameVisualResourceData? {
        resources.first { $0.id == id }
    }
}
