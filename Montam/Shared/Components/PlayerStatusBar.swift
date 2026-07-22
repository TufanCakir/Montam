//
//  PlayerStatusBar.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import SwiftData
import SwiftUI

struct PlayerStatusBar: View {

    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    private let monsters = JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

    private var save: GameSaveData? {
        saves.first
    }

    var body: some View {
        HStack(alignment: .center, spacing: 7) {
            ZStack(alignment: .bottom) {
                Image(activeMonsterImageName)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
                    .frame(width: 42, height: 42)
                    .background(.cyan.opacity(0.84))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.orange, lineWidth: 2))

                Text("TLv.\(save?.playerLevel ?? 1)")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .offset(y: 10)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text("× \(formatNumber(save?.playerPower ?? 0))")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .shadow(color: .blue, radius: 2, x: 1, y: 2)

                ProgressView(value: progressValue)
                    .tint(.green)
                    .background(Color.black.opacity(0.62))
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .overlay {
                        Text("\(formatNumber(save?.playerXP ?? 0))/\(formatNumber(save?.playerMaxXP ?? 100))")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(.green.opacity(0.92))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(height: 10)
            }
            .layoutPriority(2)

            PlayerStatusCurrency(iconId: "coin", fallbackImage: "icon_coin", amount: formatNumber(save?.coins ?? 0))
            PlayerStatusCurrency(iconId: "crystal", fallbackImage: "icon_crystal", amount: formatNumber(save?.crystals ?? 0))
        }
    }

    private var progressValue: Double {
        let xp = Double(save?.playerXP ?? 0)
        let maxXP = Double(max(save?.playerMaxXP ?? 100, 1))
        return min(max(xp / maxXP, 0), 1)
    }

    private var activeMonsterImageName: String {
        guard let activeId = ownedMonsters.first(where: \.isSelected)?.monsterId,
              let monster = monsters.first(where: { $0.id == activeId })
        else {
            return monsters.first?.monsterName ?? "mon_kyro"
        }

        return monster.monsterName
    }

    private func formatNumber(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1f M", Double(value) / 1_000_000)
        }

        if value >= 1_000 {
            return String(format: "%.1f K", Double(value) / 1_000)
        }

        return "\(value)"
    }
}

private struct PlayerStatusCurrency: View {
    let iconId: String
    let fallbackImage: String
    let amount: String

    var body: some View {
        HStack(spacing: 3) {
            GameResourceIcon(id: iconId, fallbackImage: fallbackImage)
                .frame(width: 22, height: 22)

            Text(amount)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Text("+")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
        }
        .padding(.horizontal, 4)
        .frame(width: 78, height: 30)
        .background(.blue.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.cyan.opacity(0.45), lineWidth: 2))
    }
}
