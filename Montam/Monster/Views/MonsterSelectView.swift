//
//  MonsterSelectView.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftUI

struct MonsterSelectView: View {
    let store: GameStore

    private let monsters =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let tamers =
        JSONDataLoader.load("tamer", as: [TamerData].self) ?? []

    var body: some View {
        let ownedMonstersById = store.ownedMonsters.reduce(
            into: [String: OwnedMonsterData]()
        ) { result, monster in
            result[monster.monsterId] = monster
        }
        let ownedTamersById = store.ownedTamers.reduce(
            into: [String: OwnedTamerData]()
        ) { result, tamer in
            result[tamer.tamerId] = tamer
        }
        let hasSelectedMonster = store.ownedMonsters.contains(
            where: \.isSelected
        )

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Monster wechseln")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    "Auswahl gilt für den nächsten Kampf. Im laufenden Kampf wird nicht gewechselt."
                )
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)

                monsterRows(
                    ownedMonstersById: ownedMonstersById,
                    hasSelectedMonster: hasSelectedMonster
                )

                tamerRows(ownedTamersById: ownedTamersById)
            }
            .padding(24)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppScreenBackground())
        .padding(.top, 30)
    }

    private func monsterRows(
        ownedMonstersById: [String: OwnedMonsterData],
        hasSelectedMonster: Bool
    ) -> some View {
        ForEach(monsters, id: \.id) { monster in
            let owned = ownedMonstersById[monster.id]
            SelectionRow(
                imageName: monster.monsterName,
                title: monster.name,
                subtitle: owned.map { "Lv. \($0.level) · XP \($0.xp)" }
                    ?? "Lv. 1 · immer verfügbar",
                isSelected: owned?.isSelected == true
                    || (!hasSelectedMonster
                        && monster.id == monsters.first?.id),
                isEnabled: true
            ) {
                store.selectMonster(
                    id: monster.id,
                    imageName: monster.monsterName
                )
            }
        }
    }

    @ViewBuilder
    private func tamerRows(
        ownedTamersById: [String: OwnedTamerData]
    ) -> some View {
        Text("Tamer Support")
            .font(.system(size: 24, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .padding(.top, 18)

        ForEach(tamers, id: \.id) { tamer in
            let owned = ownedTamersById[tamer.id]
            SelectionRow(
                imageName: tamer.tamerName,
                title: tamer.name,
                subtitle: owned.map {
                    "Lv. \($0.level) · Support aktiv"
                } ?? "Noch nicht besitzt",
                isSelected: owned?.isSelected == true,
                isEnabled: owned != nil
            ) {
                store.selectTamer(id: tamer.id)
            }
        }
    }
}

private struct SelectionRow: View {
    let imageName: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RemoteAssetImage(imageName: imageName)
                    .scaledToFit()
                    .frame(width: 74, height: 74)
                    .opacity(isEnabled ? 1 : 0.38)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(
                            .system(size: 21, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(
                            .system(size: 14, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(isEnabled ? .cyan : .gray)
                }

                Spacer()

                Text(isSelected ? "Aktiv" : "Wählen")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? .black : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isSelected ? .yellow : .blue)
                    .clipShape(Capsule())
                    .opacity(isEnabled ? 1 : 0.35)
            }
            .padding(12)
            .background(.blue.opacity(isSelected ? 0.68 : 0.36))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12).stroke(
                    isSelected ? .yellow : .cyan.opacity(0.45),
                    lineWidth: 2
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    RootView()
}
