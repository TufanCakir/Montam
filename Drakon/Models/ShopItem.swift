//
//  ShopItem.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

struct ShopItem: Codable, Identifiable {

    let id: String
    let storeProductId: String?
    let category: ShopCategory

    let coins: Int?
    let gems: Int?
    let rubies: Int?
    let draken: Int?
    let shards: Int?
    let eventCurrency: Int?
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
            title: "COINS",
            amount: coins,
            icon: "icon_drakon_coin"
        )
        appendReward(
            &rewards,
            title: "GEMS",
            amount: gems,
            icon: "icon_drakon_gem"
        )
        appendReward(
            &rewards,
            title: "RUBY",
            amount: rubies,
            icon: "icon_drakon_ruby"
        )
        appendReward(
            &rewards,
            title: "DRAKEN",
            amount: draken,
            icon: "icon_draken"
        )
        appendReward(
            &rewards,
            title: "SHARDS",
            amount: shards,
            icon: "icon_drakon_shard"
        )
        appendReward(
            &rewards,
            title: "EVENT",
            amount: eventCurrency,
            icon: "icon_draken_container"
        )
        appendReward(&rewards, title: "EXP", amount: exp, icon: "drakon_icon")

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
                    title: "DRAKON",
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
            ?? "egg_baby_pyro"
    }

    private func skinIcon(for id: String) -> String {
        SkinConfigLoader.load().skins.first(where: { $0.id == id })?.image
            ?? "drakon_icon"
    }

    private func characterIcon(for id: String) -> String {
        let characters: [Character]? = try? JSONLoader.load("characters")
        return characters?.first(where: { $0.id == id })?.sprite
            ?? "drakon_icon"
    }
}

struct ShopRewardLine: Hashable {
    let title: String
    let amount: Int
    let icon: String
}
