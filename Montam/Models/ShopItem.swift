//
//  ShopItem.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct ShopItem: Codable, Identifiable {

    let id: String
    let storeProductId: String?
    let category: ShopCategory

    let montamCoins: Int?
    let montamSaphirs: Int?
    let montamRubys: Int?
    let montamLiquid: Int?
    let montamShards: Int?
    let montamContainers: Int?
    let exp: Int?
    let eggId: String?
    let eggs: Int?
    let skinId: String?
    let characterId: String?
    let medalId: String?
    let medals: Int?

    let oneTimePurchase: Bool?
    let purchaseLimit: Int?
    let tag: String?
}

extension ShopItem {
    var rewardAmount: Int {
        rewardLines.first?.amount ?? 0
    }

    var rewardTitle: String {
        if rewardLines.count == 1 {
            return rewardLines[0].title
        }

        return "PACK"
    }

    var rewardIcon: String {
        rewardLines.first?.icon ?? category.icon
    }

    var rewardLines: [ShopRewardLine] {
        var rewards: [ShopRewardLine] = []

        appendReward(
            &rewards,
            title: "montamCoins",
            amount: montamCoins,
            icon: "icon_montam_coins"
        )
        appendReward(
            &rewards,
            title: "montamSaphirs",
            amount: montamSaphirs,
            icon: "icon_montam_saphir"
        )
        appendReward(
            &rewards,
            title: "montamRubys",
            amount: montamRubys,
            icon: "icon_montam_rubys"
        )
        appendReward(
            &rewards,
            title: "montamLiquid",
            amount: montamLiquid,
            icon: "icon_montam_liquid"
        )
        appendReward(
            &rewards,
            title: "montamShards",
            amount: montamShards,
            icon: "icon_montam_shards"
        )
        appendReward(
            &rewards,
            title: "montamContainers",
            amount: montamContainers,
            icon: "icon_montam_containers"
        )
        appendReward(&rewards, title: "EXP", amount: exp, icon: "montam_icon")

        if let eggId {
            rewards.append(
                ShopRewardLine(
                    title: "EI",
                    amount: max(1, eggs ?? 1),
                    icon: eggIcon(for: eggId)
                )
            )
        }

        if let skinId {
            rewards.append(
                ShopRewardLine(
                    title: "SKIN",
                    amount: 1,
                    icon: skinIcon(for: skinId)
                )
            )
        }

        if let characterId {
            rewards.append(
                ShopRewardLine(
                    title: "MONTAM",
                    amount: 1,
                    icon: characterIcon(for: characterId)
                )
            )
        }

        if let medalId {
            rewards.append(
                ShopRewardLine(
                    title: "MEDALS",
                    amount: max(1, medals ?? 1),
                    icon: "\(medalId)_icon"
                )
            )
        }

        return rewards
    }

    private func appendReward(
        _ rewards: inout [ShopRewardLine],
        title: String,
        amount: Int?,
        icon: String
    ) {
        guard let amount, amount > 0 else { return }
        rewards.append(ShopRewardLine(title: title, amount: amount, icon: icon))
    }

    private func eggIcon(for id: String) -> String {
        EggConfigLoader.load().eggs.first(where: { $0.id == id })?.eggImage
            ?? "egg_feral_pyron"
    }

    private func skinIcon(for id: String) -> String {
        SkinConfigLoader.load().skins.first(where: { $0.id == id })?.image
            ?? "montam_icon"
    }

    private func characterIcon(for id: String) -> String {
        let characters: [Character]? = try? JSONLoader.load("characters")
        return characters?.first(where: { $0.id == id })?.sprite
            ?? "montam_icon"
    }
}

struct ShopRewardLine: Hashable {
    let title: String
    let amount: Int
    let icon: String
}
