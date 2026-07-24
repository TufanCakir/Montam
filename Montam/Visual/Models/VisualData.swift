//
//  VisualData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct GameVisualCatalogData: Codable {
    let resources: [GameVisualResourceData]
}

struct GameVisualResourceData: Codable, Identifiable {
    let id: String
    let imageName: String
}
