//
//  StarterEggConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct StarterEggConfig: Codable {
    let title: String
    let subtitle: String
    let eggs: [StarterEgg]
}

struct StarterEgg: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let characterId: String
    let eggImage: String
    let previewImage: String
    let accentColor: String
}
