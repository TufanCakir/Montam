//
//  OwnedSupporterData.swift
//  Montam
//
//  Created by Tufan Cakir on 25.07.26.
//

import SwiftData

@Model
final class OwnedSupporterData {

    var bannerId: String
    var characterId: String
    var imageName: String

    var level: Int
    var xp: Int

    var isMonster: Bool
    var isSelected: Bool

    init(
        bannerId: String,
        characterId: String,
        imageName: String,
        level: Int = 1,
        xp: Int = 0,
        isMonster: Bool,
        isSelected: Bool = true
    ) {
        self.bannerId = bannerId
        self.characterId = characterId
        self.imageName = imageName
        self.level = level
        self.xp = xp
        self.isMonster = isMonster
        self.isSelected = isSelected
    }
}
