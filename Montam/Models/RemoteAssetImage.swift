//
//  RemoteAssetImage.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI
import UIKit

struct RemoteAssetImage: View {
    let name: String
    let fallbackSystemName: String?
    @State private var loadedImage: UIImage?

    init(name: String, fallbackSystemName: String? = nil) {
        self.name = name
        self.fallbackSystemName = fallbackSystemName
    }

    var body: some View {
        Group {
            if let image = loadedImage ?? cachedImage() {
                Image(uiImage: image)
                    .resizable()
            } else if let fallbackSystemName {
                Image(systemName: fallbackSystemName)
                    .resizable()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(MontamPalette.gold)
            } else {
                MontamPalette.panel
                    .overlay {
                        Text("Montam")
                            .font(
                                .system(
                                    size: 14,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                    }
            }
        }
        .onAppear(perform: loadIfNeeded)
        .onChange(of: name) { _, _ in
            loadedImage = nil
            loadIfNeeded()
        }
    }

    private func cachedImage() -> UIImage? {
        guard let url = RemoteAssetManager.shared.localURL(for: name) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    private func loadIfNeeded() {
        if let image = cachedImage() {
            loadedImage = image
            return
        }

        let manifest = JSONLoader.manifest()
        guard
            let asset = manifest.assets.first(where: { $0.id == name }),
            let baseURL = manifest.assetBaseURL.flatMap(URL.init(string:))
        else {
            return
        }

        DispatchQueue.global(qos: .utility).async {
            _ = RemoteAssetManager.shared.download(
                asset: asset,
                baseURL: baseURL
            )
            let image = cachedImage()
            DispatchQueue.main.async {
                loadedImage = image
            }
        }
    }
}
