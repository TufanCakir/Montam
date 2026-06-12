//
//  TeamManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import SwiftUI

class TeamManager: ObservableObject {

    @Published var ownedCharacters: [OwnedCharacter] = [] {
        didSet {
            if !isLoading { save() }
        }
    }

    @Published var activeTeam: [OwnedCharacter] = [] {
        didSet {
            if !isLoading { save() }
        }
    }

    var maxTeamSize: Int {
        max(1, GameConfigManager.shared.config.team.maxActiveTeamSize)
    }

    private let ownedKey = "saved_owned_characters"
    private let teamKey = "saved_active_team_ids"

    private var isLoading = false

    init() {
        load()
    }

    func reset() {
        ownedCharacters = []
        activeTeam = []

        UserDefaults.standard.removeObject(forKey: ownedKey)
        UserDefaults.standard.removeObject(forKey: teamKey)
    }

    // MARK: Add

    func addToTeam(_ character: OwnedCharacter) {

        guard activeTeam.count < maxTeamSize else { return }
        guard !isInTeam(character) else { return }

        activeTeam.append(character)
    }

    func upgradeStars(for character: OwnedCharacter) {
        guard
            let index = ownedCharacters.firstIndex(where: {
                $0.id == character.id
            })
        else { return }
        ownedCharacters[index].addStars(1)
        ownedCharacters = ownedCharacters
        activeTeam = activeTeam.map {
            $0.id == character.id ? ownedCharacters[index] : $0
        }
    }

    // MARK: Remove

    func removeFromTeam(_ character: OwnedCharacter) {

        guard activeTeam.count > 1 else { return }

        activeTeam.removeAll { $0.id == character.id }
    }

    func isInTeam(_ character: OwnedCharacter) -> Bool {
        activeTeam.contains { $0.id == character.id }
    }

    // MARK: Save

    private func save() {

        let encoder = JSONEncoder()
        let defaults = UserDefaults.standard

        if let ownedData = try? encoder.encode(ownedCharacters) {
            defaults.set(ownedData, forKey: ownedKey)
        }

        let ids = activeTeam.map { $0.id }
        defaults.set(ids, forKey: teamKey)
    }

    func addOwnedCharacter(_ newChar: OwnedCharacter) {

        // ⭐ Prüfen ob gleicher Base Character existiert
        if let index = ownedCharacters.firstIndex(where: {
            $0.baseId == newChar.baseId
        }) {
            ownedCharacters[index].addStars(1)
            return
        }

        // ⭐ Neu hinzufügen
        ownedCharacters.append(newChar)

        // ⭐ Auto ins Team wenn leer
        if activeTeam.isEmpty {
            activeTeam.append(newChar)
        }
    }

    // MARK: - Add Character (Dupe Handling)

    func obtainCharacter(_ character: Character) {

        // ⭐ Prüfen ob schon vorhanden
        if let index = ownedCharacters.firstIndex(where: {
            $0.baseId == character.id
        }) {
            ownedCharacters[index].addStars(1)
            return
        }

        // ⭐ Neuer Charakter
        let owned = OwnedCharacter(base: character)
        ownedCharacters.append(owned)

        // Auto Team wenn leer
        if activeTeam.isEmpty {
            activeTeam = [owned]
        }
    }

    // MARK: Load

    private func load() {

        isLoading = true

        let decoder = JSONDecoder()
        let defaults = UserDefaults.standard
        var removedLegacyCharacters = false

        // Load Owned FIRST
        if let ownedData = defaults.data(forKey: ownedKey),
            let decodedOwned = try? decoder.decode(
                [OwnedCharacter].self,
                from: ownedData
            )
        {
            ownedCharacters = decodedOwned.filter {
                $0.baseId.hasPrefix("character_montam_")
            }
            removedLegacyCharacters =
                ownedCharacters.count != decodedOwned.count
        }

        // Load Team AFTER ownedCharacters exists
        if let savedIDs = defaults.stringArray(forKey: teamKey) {

            activeTeam = savedIDs.compactMap { id in
                ownedCharacters.first(where: { $0.id == id })
            }
        }

        // Safety fallback
        if activeTeam.isEmpty,
            let first = ownedCharacters.first
        {

            activeTeam = [first]
        }

        isLoading = false

        if removedLegacyCharacters {
            save()
        }
    }
}
