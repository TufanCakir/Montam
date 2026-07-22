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
        } else {
            Image(imageName)
                .resizable()
        }
    }

    private var cachedImage: UIImage? {
        let cachedURL = RemoteContentService.cachedAssetURL(named: imageName)
        guard FileManager.default.fileExists(atPath: cachedURL.path()) else {
            return nil
        }

        return UIImage(contentsOfFile: cachedURL.path())
    }
}
