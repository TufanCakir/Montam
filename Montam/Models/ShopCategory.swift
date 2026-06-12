//
//  ShopCategory.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct ShopCategory: Codable, Hashable, Identifiable {

    let id: String
    let icon: String
    let color: String

    var uiColor: Color {
        switch color.lowercased() {
        case "cyan": return .cyan
        case "purple": return .purple
        case "yellow": return .yellow
        case "orange": return .orange
        case "pink": return .pink
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        default: return .white
        }
    }
}
