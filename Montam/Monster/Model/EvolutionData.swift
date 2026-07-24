//
//  EvolutionData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct EvolutionData: Codable, Identifiable {
    let id: String
    let monsterId: String
    let note: String?
}
