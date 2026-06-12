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

    init(name: String, fallbackSystemName: String? = nil) {
        self.name = name
        self.fallbackSystemName = fallbackSystemName
    }

    var body: some View {
        if let url = RemoteAssetManager.shared.localURL(for: name),
            let image = UIImage(contentsOfFile: url.path)
        {
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
                            .system(size: 14, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                }
        }
    }
}
