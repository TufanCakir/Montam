//
//  RemoteAssetImage.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI
import UIKit

struct RemoteAssetImage: View {
    let imageName: String
    private static let imageCache = NSCache<NSString, UIImage>()

    static func invalidateCache() {
        imageCache.removeAllObjects()
    }

    var body: some View {
        if let image = cachedImage {
            Image(uiImage: image)
                .resizable()
        } else if let image = bundledStartupImage {
            Image(uiImage: image)
                .resizable()
        } else {
            RemoteAssetPlaceholder()
        }
    }

    private var cachedImage: UIImage? {
        for cachedURL in candidateCachedURLs {
            let cacheKey = cachedURL.path() as NSString
            if let image = Self.imageCache.object(forKey: cacheKey) {
                return image
            }

            guard FileManager.default.fileExists(atPath: cachedURL.path())
            else {
                continue
            }

            guard let image = UIImage(contentsOfFile: cachedURL.path()) else {
                continue
            }

            Self.imageCache.setObject(image, forKey: cacheKey)
            return image
        }

        return nil
    }

    private var bundledStartupImage: UIImage? {
        guard Self.bundledStartupImageNames.contains(imageName) else {
            return nil
        }

        let cacheKey = "bundle:\(imageName)" as NSString
        if let image = Self.imageCache.object(forKey: cacheKey) {
            return image
        }

        guard let image = UIImage(named: imageName) else {
            return nil
        }

        Self.imageCache.setObject(image, forKey: cacheKey)
        return image
    }

    private static let bundledStartupImageNames: Set<String> = [
        "montam_logo",
        "montem_badge_logo",
    ]

    private var candidateCachedURLs: [URL] {
        var urls = [RemoteContentService.cachedAssetURL(named: imageName)]

        guard !imageName.contains(".") else {
            return urls
        }

        urls.append(
            contentsOf: ["png", "jpg", "jpeg", "webp"].map {
                RemoteContentService.cachedAssetURL(
                    named: "\(imageName).\($0)"
                )
            }
        )
        return urls
    }
}

private struct RemoteAssetPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.10))
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.cyan.opacity(0.55))
            }
            .aspectRatio(1, contentMode: .fit)
    }
}
