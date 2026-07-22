//
//  TeamComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

enum TeamSection: CaseIterable, Identifiable {
    case partner
    case support
    case kamerad
    case spSupport

    var id: Self { self }

    var title: String {
        switch self {
        case .partner: "Partner"
        case .support: "Support"
        case .kamerad: "Kamerad"
        case .spSupport: "SP-Support"
        }
    }
}

struct PartnerTeamContent: View {
    let rows: [TeamMonsterRow]
    let evolution: TeamEvolutionState?
    let onSelect: (String) -> Void
    let onEquipAppearance: (TeamAppearanceRow, String) -> Void
    let onEvolve: (EvolutionData) -> Void

    var body: some View {
        if rows.isEmpty {
            CompactTeamInfo(
                title: "Kein Partner",
                message: "Wähle oder beschwöre zuerst ein Monster."
            )
        } else {
            VStack(spacing: 10) {
                if let active = rows.first(where: \.isSelected) ?? rows.first {
                    ActiveMonsterPanel(
                        row: active,
                        evolution: evolution,
                        onEquipAppearance: onEquipAppearance,
                        onEvolve: onEvolve
                    )
                }

                ForEach(rows) { row in
                    TeamMonsterListRow(row: row) {
                        onSelect(row.id)
                    }
                }
            }
        }
    }
}

struct SupportTeamContent: View {
    let rows: [TeamTamerRow]
    let onSelect: (String) -> Void

    var body: some View {
        if rows.isEmpty {
            CompactTeamInfo(
                title: "Kein Support",
                message: "Supporter werden aus deinen Besitzdaten angezeigt."
            )
        } else {
            VStack(spacing: 10) {
                ForEach(rows) { row in
                    Button {
                        onSelect(row.id)
                    } label: {
                        HStack(spacing: 10) {
                            RemoteAssetImage(imageName: row.imageName)
                                .scaledToFit()
                                .frame(width: 58, height: 58)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(row.name)
                                    .font(
                                        .system(
                                            size: 18,
                                            weight: .heavy,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundStyle(.white)
                                Text(
                                    "Lv. \(row.level)  ATK +\(percent(row.attackBonus))  DEF +\(percent(row.defenseBonus))  HP +\(percent(row.healthBonus))"
                                )
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .bold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.cyan)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                            }

                            Spacer()

                            Image(
                                systemName: row.isSelected
                                    ? "checkmark.circle.fill" : "circle"
                            )
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(
                                row.isSelected ? .yellow : .cyan.opacity(0.55)
                            )
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 72)
                        .background(
                            Color.black.opacity(row.isSelected ? 0.36 : 0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct TeamTitleBar: View {
    let section: TeamSection

    var body: some View {
        HStack(spacing: 8) {
            Text(section.title.uppercased())
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            Image(systemName: "info.circle.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(.horizontal, 14)
        .frame(height: 42)
        .background(Color.cyan.opacity(0.42))
        .overlay(alignment: .bottom) {
            Rectangle().fill(.cyan.opacity(0.65)).frame(height: 1)
        }
    }
}

struct TeamSectionTabs: View {
    @Binding var selectedSection: TeamSection

    var body: some View {
        HStack(spacing: 6) {
            ForEach(TeamSection.allCases) { section in
                Button {
                    selectedSection = section
                } label: {
                    Text(section.title)
                        .font(
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(
                            selectedSection == section ? .black : .cyan
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(
                            selectedSection == section
                                ? Color.yellow : Color.black.opacity(0.28)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }
}

struct CompactTeamInfo: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text(message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)
                .multilineTextAlignment(.center)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TeamBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

private struct ActiveMonsterPanel: View {
    let row: TeamMonsterRow
    let evolution: TeamEvolutionState?
    let onEquipAppearance: (TeamAppearanceRow, String) -> Void
    let onEvolve: (EvolutionData) -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                RemoteAssetImage(imageName: row.imageName)
                    .scaledToFit()
                    .frame(width: 118, height: 118)
                    .padding(8)
                    .background(Color.black.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(
                            .cyan.opacity(0.55),
                            lineWidth: 1
                        )
                    )

                VStack(alignment: .leading, spacing: 7) {
                    Text(row.name)
                        .font(
                            .system(size: 24, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    StatLine(title: "Level", value: "\(row.level)")
                    StatLine(
                        title: "Power",
                        value: GameNumberFormatter.compact(row.power)
                    )
                    StatLine(title: "Rarity", value: row.rarity.uppercased())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            TeamXPBar(value: row.xp, maxValue: row.maxXP)

            if let evolution {
                TeamEvolutionButton(evolution: evolution, onEvolve: onEvolve)
            }

            if !row.appearances.isEmpty {
                TeamAppearanceStrip(
                    appearances: row.appearances,
                    monsterId: row.id,
                    onEquip: onEquipAppearance
                )
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(
                .cyan.opacity(0.5),
                lineWidth: 1
            )
        )
    }
}

private struct TeamEvolutionButton: View {
    let evolution: TeamEvolutionState
    let onEvolve: (EvolutionData) -> Void

    var body: some View {
        Button {
            onEvolve(evolution.evolution)
        } label: {
            HStack(spacing: 8) {
                RemoteAssetImage(imageName: evolution.evolution.targetImageName)
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text(
                        evolution.canEvolve
                            ? "Entwicklung starten"
                            : "Entwicklung ab Lv. \(evolution.evolution.requiredLevel)"
                    )
                    Text(evolution.evolution.displayName)
                        .font(
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .opacity(0.82)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                Spacer()
                Image(
                    systemName: evolution.canEvolve ? "sparkles" : "lock.fill"
                )
            }
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .foregroundStyle(
                evolution.canEvolve ? .black : .white.opacity(0.72)
            )
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                evolution.canEvolve ? Color.yellow : Color.gray.opacity(0.45)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
        .disabled(!evolution.canEvolve)
    }
}

private struct TeamAppearanceStrip: View {
    let appearances: [TeamAppearanceRow]
    let monsterId: String
    let onEquip: (TeamAppearanceRow, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Aussehen")
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(appearances) { appearance in
                        Button {
                            onEquip(appearance, monsterId)
                        } label: {
                            VStack(spacing: 4) {
                                RemoteAssetImage(
                                    imageName: appearance.imageName
                                )
                                .scaledToFit()
                                .frame(width: 58, height: 58)
                                .opacity(appearance.isUnlocked ? 1 : 0.35)

                                Text(
                                    appearance.isUnlocked
                                        ? appearance.title
                                        : "Lv. \(appearance.requiredLevel)"
                                )
                                .font(
                                    .system(
                                        size: 10,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(
                                    appearance.isEquipped ? .black : .white
                                )
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                            }
                            .frame(width: 74, height: 86)
                            .background(
                                appearance.isEquipped
                                    ? Color.yellow : Color.black.opacity(0.24)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    .cyan.opacity(0.5),
                                    lineWidth: 1
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(!appearance.isUnlocked)
                    }
                }
            }
        }
    }
}

private struct TeamMonsterListRow: View {
    let row: TeamMonsterRow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                RemoteAssetImage(imageName: row.imageName)
                    .scaledToFit()
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(row.name)
                            .font(
                                .system(
                                    size: 17,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text("Lv. \(row.level)")
                            .font(
                                .system(
                                    size: 12,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.green)
                    }
                    Text("Power \(GameNumberFormatter.compact(row.power))")
                        .font(
                            .system(size: 12, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                }

                Spacer()

                Image(
                    systemName: row.isSelected
                        ? "checkmark.circle.fill" : "circle"
                )
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(row.isSelected ? .yellow : .cyan.opacity(0.55))
            }
            .padding(.horizontal, 10)
            .frame(height: 68)
            .background(Color.black.opacity(row.isSelected ? 0.36 : 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}

private struct TeamXPBar: View {
    let value: Int
    let maxValue: Int

    private var progress: Double {
        min(max(Double(value) / Double(max(maxValue, 1)), 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("XP")
                Spacer()
                Text(
                    "\(GameNumberFormatter.compact(value))/\(GameNumberFormatter.compact(maxValue))"
                )
            }
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .foregroundStyle(.green)

            ProgressView(value: progress)
                .tint(.green)
                .frame(height: 8)
                .background(Color.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

private struct StatLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.cyan.opacity(0.8))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
        }
        .font(.system(size: 13, weight: .heavy, design: .rounded))
    }
}

private func percent(_ value: Double) -> String {
    String(format: "%.0f%%", value * 100)
}
