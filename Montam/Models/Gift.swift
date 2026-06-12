//
//  Gift.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct Gift: Codable, Identifiable {
    let id: String
    let title: String?
    let icon: String?
    let iconColor: String?
    let colors: [String]?

    let type: GiftType
    let amount: Int?
    let characterId: String?
    let eggId: String?
    let skinId: String?
    let note: String?
}

enum GiftType: String, Codable {
    case montamCoins
    case montamSaphirs
    case exp
    case montamRubys
    case montamShards
    case montamContainers
    case montamLiquid
    case egg
    case montam
    case skin
}

final class GiftLoader {
    static func load() -> [Gift] {
        do {
            return try JSONLoader.load("gifts")
        } catch {
            print("gifts.json konnte nicht geladen werden:", error)
            return []
        }
    }
}

extension Color {
    static func from(_ name: String?) -> Color {
        guard let name else { return .white }

        switch name.lowercased() {
        case "yellow": return .yellow
        case "orange": return .orange
        case "cyan": return .cyan
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "gray": return .gray
        default: return .white
        }
    }
}
