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
        let cachedURL = RemoteContentService.cachedAssetURL(named: imageName)
        guard FileManager.default.fileExists(atPath: cachedURL.path()) else {
            return nil
        }

        return UIImage(contentsOfFile: cachedURL.path())
    }

    private var bundledStartupImage: UIImage? {
        guard Self.bundledStartupImageNames.contains(imageName) else {
            return nil
        }

        return UIImage(named: imageName)
    }

    private static let bundledStartupImageNames: Set<String> = [
        "montam_logo",
        "montem_badge_logo",
    ]
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
