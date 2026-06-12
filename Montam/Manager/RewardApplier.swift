//
//  RewardApplier.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

enum RewardApplier {
    static func apply(
        type: GiftType,
        amount: Int?,
        characterId: String?,
        eggId: String?,
        skinId: String?,
        teamManager: TeamManager?
    ) {
        let amount = amount ?? 0

        switch type {
        case .montamCoins:
            MontamCoinsManager.shared.add(amount)
        case .montamSaphirs:
            MontamSaphirsManager.shared.add(amount)
        case .exp:
            PlayerProgressManager.shared.addEXP(amount)
        case .montamRubys:
            MontamRubysManager.shared.add(amount)
        case .montamShards:
            MontamShardsManager.shared.add(amount)
        case .montamContainers:
            MontamContainersManager.shared.add(amount)
        case .montamLiquid:
            MontamLiquidManager.shared.add(amount)
        case .egg:
            if let eggId {
                EggInventoryManager.shared.add(max(1, amount), eggId: eggId)
            }
        case .skin:
            if let skinId {
                SkinInventoryManager.shared.unlock(skinId)
            }
        case .montam:
            addMontam(characterId: characterId, teamManager: teamManager)
        }
    }

    private static func addMontam(
        characterId: String?,
        teamManager: TeamManager?
    ) {
        guard let characterId, let teamManager else { return }

        do {
            let characters: [Character] = try JSONLoader.load("characters")
            guard
                let character = characters.first(where: { $0.id == characterId }
                )
            else {
                print("Reward Montam not found:", characterId)
                return
            }
            teamManager.addOwnedCharacter(OwnedCharacter(base: character))
        } catch {
            print("Reward Montam load failed:", error)
        }
    }
}
