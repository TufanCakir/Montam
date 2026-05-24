//
//  RemoteAssetImage.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
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
                .foregroundStyle(DrakonBladePalette.gold)
        } else {
            DrakonBladePalette.panel
                .overlay {
                    Text("DRK")
                        .font(
                            .system(size: 14, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                }
        }
    }
}
