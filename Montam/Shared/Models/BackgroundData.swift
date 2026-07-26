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
    let skyImageName: String?
    let farImageName: String?
    let midImageName: String?
    let groundImageName: String?

    var resolvedBackgroundImageName: String? {
        imageName.isEmpty ? nil : imageName
    }

    var resolvedSkyImageName: String? {
        skyImageName?.isEmpty == false
            ? skyImageName : resolvedBackgroundImageName
    }

    var resolvedFarImageName: String? {
        farImageName?.isEmpty == false ? farImageName : nil
    }

    var resolvedMidImageName: String? {
        midImageName?.isEmpty == false ? midImageName : nil
    }

    var resolvedGroundImageName: String? {
        groundImageName?.isEmpty == false ? groundImageName : nil
    }

    var resolvedEnvironmentImageNames: [String] {
        [
            resolvedSkyImageName,
            resolvedFarImageName,
            resolvedMidImageName,
            resolvedGroundImageName,
        ].compactMap { $0 }
    }
}
