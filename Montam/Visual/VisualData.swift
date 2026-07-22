//
//  VisualData.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import Foundation

struct GameVisualCatalogData: Codable {
    let resources: [GameVisualResourceData]
}

struct GameVisualResourceData: Codable, Identifiable {
    let id: String
    let renderMode: VisualRenderMode
    let imageName: String?
    let shape: String
    let colors: [String]
    let glow: Bool
    let animation: String?
}

enum VisualRenderMode: String, Codable {
    case generated
    case image
}
