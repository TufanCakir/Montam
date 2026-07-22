//
//  BackgroundData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct BackgroundData: Codable {
    let id: String
    let imageName: String?
    let backgroundImage: String?
    let groundImageName: String?
    let groundImage: String?
    let proceduralStyle: String?
    let skyTopColor: String?
    let skyBottomColor: String?
    let accentColor: String?
    let groundStyle: String?
    let groundTopColor: String?
    let groundBottomColor: String?
    let horizonColor: String?
    let particleStyle: String?
    let yOffset: Double?
    let xOffset: Double?
    let zOffset: Double?

    var resolvedBackgroundImageName: String? {
        nonEmpty(imageName) ?? nonEmpty(backgroundImage)
    }

    var resolvedGroundImageName: String? {
        nonEmpty(groundImageName) ?? nonEmpty(groundImage)
    }

    private func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else {
            return nil
        }

        return value
    }
}
