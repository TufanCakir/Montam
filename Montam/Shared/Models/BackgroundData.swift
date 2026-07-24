//
//  BackgroundData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct BackgroundData: Codable {
    let id: String
    let imageName: String

    var resolvedBackgroundImageName: String? {
        imageName.isEmpty ? nil : imageName
    }
}
