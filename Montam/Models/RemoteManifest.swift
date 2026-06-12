//
//  RemoteManifest.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct RemoteManifest: Codable {
    let jsonFiles: [String]
    let assetBaseURL: String?
    let musicBaseURL: String?
    let assets: [RemoteAsset]
    let music: [RemoteAsset]

    enum CodingKeys: String, CodingKey {
        case jsonFiles
        case assetBaseURL
        case musicBaseURL
        case assets
        case music
    }

    init(
        jsonFiles: [String],
        assetBaseURL: String?,
        musicBaseURL: String? = nil,
        assets: [RemoteAsset],
        music: [RemoteAsset] = []
    ) {
        self.jsonFiles = jsonFiles
        self.assetBaseURL = assetBaseURL
        self.musicBaseURL = musicBaseURL
        self.assets = assets
        self.music = music
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonFiles =
            try container.decodeIfPresent([String].self, forKey: .jsonFiles)
            ?? []
        assetBaseURL = try container.decodeIfPresent(
            String.self,
            forKey: .assetBaseURL
        )
        musicBaseURL = try container.decodeIfPresent(
            String.self,
            forKey: .musicBaseURL
        )
        assets =
            try container.decodeIfPresent([RemoteAsset].self, forKey: .assets)
            ?? []
        music =
            try container.decodeIfPresent([RemoteAsset].self, forKey: .music)
            ?? []
    }
}

struct RemoteAsset: Codable, Identifiable {
    let id: String
    let file: String
}
