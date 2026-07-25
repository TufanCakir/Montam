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

    var id: Self { self }

    var title: String {
        switch self {
        case .partner: "Partner"
        case .support: "Support"
        }
    }
}

struct PartnerTeamContent: View {
    let rows: [TeamMonsterRow]
    let evolution: TeamEvolutionState?
    let onSelect: (String) -> Void
    let onEquipAppearance: (TeamAppearanceRow, String) -> Void
    let onEvolve: (TeamEvolutionState) -> Void

    @State private var isAppearancePickerVisible = false
    @State private var pendingSelection: TeamMonsterRow?

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        if rows.isEmpty {
            CompactTeamInfo(
                title: "Kein Partner",
                message: "Partner werden aus deinen Spieldaten geladen."
            )
        } else {
            ZStack {
                VStack(spacing: 14) {
                    if let active = rows.first(where: \.isSelected)
                        ?? rows.first
                    {
                        ActiveMonsterPanel(
                            row: active,
                            evolution: evolution,
                            isAppearancePickerVisible:
                                $isAppearancePickerVisible,
                            onEquipAppearance: onEquipAppearance,
                            onEvolve: onEvolve
                        )
                    }

                    VStack(spacing: 10) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(rows) { row in
                                TeamMonsterGridTile(row: row) {
                                    pendingSelection = row
                                }
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.30))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cyan.opacity(0.65), lineWidth: 2)
                    )
                }

                if let pendingSelection {
                    TeamMonsterSelectionPopup(
                        row: pendingSelection,
                        onCancel: {
                            self.pendingSelection = nil
                        },
                        onConfirm: {
                            onSelect(pendingSelection.id)
                            self.pendingSelection = nil
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
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
    @Binding var isAppearancePickerVisible: Bool
    let onEquipAppearance: (TeamAppearanceRow, String) -> Void
    let onEvolve: (TeamEvolutionState) -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.cyan.opacity(0.16))
                        .overlay(TeamTechGrid().opacity(0.65))

                    RemoteAssetImage(imageName: row.imageName)
                        .scaledToFit()
                        .padding(10)

                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.cyan)
                        .padding(8)
                }
                .frame(width: 142, height: 142)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.cyan.opacity(0.62), lineWidth: 1.4)
                )

                VStack(alignment: .leading, spacing: 7) {
                    TeamInfoBlock(
                        title: "Digitationsstufe",
                        value: row.rarity.uppercased()
                    )
                    TeamInfoBlock(title: "Name", value: row.displayName)
                    TeamInfoBlock(
                        title: "Kampf-Typ",
                        value: "Power \(GameNumberFormatter.compact(row.power))"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(alignment: .bottom, spacing: 10) {
                VStack(spacing: 0) {
                    Text("LV")
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.yellow)
                    Text("\(row.level)")
                        .font(
                            .system(size: 30, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                }
                .frame(width: 62)

                TeamXPBar(value: row.xp, maxValue: row.maxXP)
                    .padding(.bottom, 5)
            }

            Button {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    isAppearancePickerVisible.toggle()
                }
            } label: {
                TeamLargeActionLabel(
                    title: "Aussehen ändern",
                    systemName: "paintpalette.fill",
                    color: .cyan,
                    foreground: .white
                )
            }
            .buttonStyle(.plain)

            if let evolution {
                Button {
                    onEvolve(evolution)
                } label: {
                    TeamLargeActionLabel(
                        title: evolution.canEvolve
                            ? "Transformieren"
                            : "Transformieren ab Lv. \(evolution.targetAppearance.requiredLevel)",
                        systemName: evolution.canEvolve
                            ? "sparkles" : "lock.fill",
                        color: evolution.canEvolve
                            ? .yellow : .gray.opacity(0.55),
                        foreground: evolution.canEvolve
                            ? .black : .white.opacity(0.72)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!evolution.canEvolve)
            } else {
                Text("Keine weitere Transformation")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan.opacity(0.78))
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Color.black.opacity(0.18))
                    .clipShape(Capsule())
            }

            if isAppearancePickerVisible {
                TeamAppearanceStrip(
                    appearances: row.appearances,
                    monsterId: row.id,
                    onEquip: onEquipAppearance
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(14)
        .background(Color.blue.opacity(0.34))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(
                .cyan.opacity(0.72),
                lineWidth: 2
            )
        )
    }
}

private struct TeamInfoBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(Color.black.opacity(0.24))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct TeamTechGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let step: CGFloat = 18
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += step
                }

                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += step
                }
            }
            .stroke(.cyan.opacity(0.28), lineWidth: 1)
        }
    }
}

private struct TeamLargeActionLabel: View {
    let title: String
    let systemName: String
    let color: Color
    let foreground: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .black))
            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(foreground)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(color.opacity(0.9))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.black.opacity(0.38), lineWidth: 1.5))
    }
}

private struct TeamMonsterGridTile: View {
    let row: TeamMonsterRow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RemoteAssetImage(imageName: row.imageName)
                    .scaledToFit()
                    .frame(height: 74)

                Text(row.displayName)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("Lv. \(row.level)")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .frame(height: 128)
            .background(Color.black.opacity(row.isSelected ? 0.38 : 0.22))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(
                    row.isSelected ? .yellow : .cyan.opacity(0.35),
                    lineWidth: row.isSelected ? 2 : 1
                )
            )
            .overlay(alignment: .topTrailing) {
                if row.isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.yellow)
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct TeamMonsterSelectionPopup: View {
    let row: TeamMonsterRow
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture(perform: onCancel)

            VStack(spacing: 12) {
                Text(row.displayName)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                RemoteAssetImage(imageName: row.imageName)
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                Text(
                    "Lv. \(row.level) · Power \(GameNumberFormatter.compact(row.power))"
                )
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
                .lineLimit(1)

                Button(action: onConfirm) {
                    TeamLargeActionLabel(
                        title: row.isSelected
                            ? "Leveln beginnen" : "Auswählen und leveln",
                        systemName: "play.fill",
                        color: .yellow,
                        foreground: .black
                    )
                }
                .buttonStyle(.plain)

                Button(action: onCancel) {
                    Text("Schließen")
                        .font(
                            .system(size: 15, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .frame(height: 34)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(width: 292)
            .background(Color.blue.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(
                    .cyan.opacity(0.8),
                    lineWidth: 2
                )
            )
            .shadow(color: .black.opacity(0.45), radius: 14, y: 8)
        }
    }
}

struct TeamEvolutionPreviewOverlay: View {
    let preview: TeamEvolutionPreview

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Transformation")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 14) {
                    RemoteAssetImage(imageName: preview.sourceImageName)
                        .scaledToFit()
                        .frame(width: 94, height: 94)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.cyan)

                    RemoteAssetImage(imageName: preview.targetImageName)
                        .scaledToFit()
                        .frame(width: 104, height: 104)
                }

                Text(preview.targetName)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(18)
            .frame(maxWidth: 320)
            .background(Color.blue.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.cyan.opacity(0.85), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.45), radius: 14, y: 8)
        }
    }
}

private struct TeamAppearanceStrip: View {
    let appearances: [TeamAppearanceRow]
    let monsterId: String
    let onEquip: (TeamAppearanceRow, String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(appearances) { appearance in
                    Button {
                        onEquip(appearance, monsterId)
                    } label: {
                        VStack(spacing: 4) {
                            RemoteAssetImage(imageName: appearance.imageName)
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

private func percent(_ value: Double) -> String {
    String(format: "%.0f%%", value * 100)
}
