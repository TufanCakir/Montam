//
//  SkinInventoryManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class SkinInventoryManager: ObservableObject {
    static let shared = SkinInventoryManager()

    @Published private(set) var ownedSkinIds: Set<String> = []
    @Published private(set) var equippedSkinIds: [String: String] = [:]

    private let key = "montam_owned_skins"
    private let equippedKey = "montam_equipped_skins"

    private init() {
        ownedSkinIds = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        loadEquipped()
    }

    func unlock(_ id: String) {
        ownedSkinIds.insert(id)
        save()
    }

    func owns(_ id: String) -> Bool {
        ownedSkinIds.contains(id)
    }

    func isUnlocked(_ skin: MontamSkinDefinition) -> Bool {
        skin.id == "default" || owns(skin.id)
    }

    func equippedSkinId(for characterId: String) -> String {
        equippedSkinIds[characterId] ?? "default"
    }

    func equip(_ skin: MontamSkinDefinition) {
        guard isUnlocked(skin) else { return }
        equippedSkinIds[skin.characterId] = skin.id
        saveEquipped()
    }

    func activeImage(for character: Character) -> String {
        let equippedId = equippedSkinId(for: character.id)

        if let skin = SkinConfigLoader.load().skins.first(where: {
            $0.characterId == character.id && $0.id == equippedId
                && isUnlocked($0)
        }) {
            return skin.image
        }

        if let localSkin = character.skins.first(where: { $0.id == equippedId })
        {
            return localSkin.sprite
        }

        return character.sprite
    }

    func reset() {
        ownedSkinIds.removeAll()
        equippedSkinIds.removeAll()
        save()
        saveEquipped()
    }

    private func save() {
        UserDefaults.standard.set(Array(ownedSkinIds), forKey: key)
    }

    private func saveEquipped() {
        if let data = try? JSONEncoder().encode(equippedSkinIds) {
            UserDefaults.standard.set(data, forKey: equippedKey)
        }
    }

    private func loadEquipped() {
        guard let data = UserDefaults.standard.data(forKey: equippedKey),
            let decoded = try? JSONDecoder().decode(
                [String: String].self,
                from: data
            )
        else {
            equippedSkinIds = [:]
            return
        }

        equippedSkinIds = decoded
    }
}
