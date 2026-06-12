//
//  GameLayout.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct GameLayout<Content: View>: View {
    @Binding var selectedTab: RootView.Tab

    let content: Content

    init(
        selectedTab: Binding<RootView.Tab>,
        @ViewBuilder content: () -> Content
    ) {
        self._selectedTab = selectedTab
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 5) {
            GlobalGameHeader()

            content

                .id(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            GlobalGameFooter(selectedTab: $selectedTab)
                .padding(.horizontal, 10)
        }
        .background {
            MontamBackground()
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct GlobalGameHeader: View {
    @ObservedObject private var montamCoins = MontamCoinsManager.shared
    @ObservedObject private var montamSaphirs = MontamSaphirsManager.shared
    @ObservedObject private var montamRubys = MontamRubysManager.shared
    @ObservedObject private var montamContainers = MontamContainersManager
        .shared
    @ObservedObject private var montamLiquid = MontamLiquidManager.shared
    @ObservedObject private var montamShards = MontamShardsManager.shared
    @ObservedObject private var progress = PlayerProgressManager.shared

    private var rank: Int {
        max(1, ((progress.level - 1) / 10) + 1)
    }

    private var expRatio: Double {
        guard progress.requiredEXP > 0 else { return 0 }
        return min(1, Double(progress.exp) / Double(progress.requiredEXP))
    }

    private var rewardIcons: EventRewardIconConfig {
        GameConfigManager.shared.config.eventUI?.rewardIcons ?? .fallback
    }

    var body: some View {
        VStack(spacing: 7) {
            HStack(spacing: 9) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("LV \(progress.level)")
                            .font(
                                .system(
                                    size: 16,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)

                        Text("RANK \(rank)")
                            .font(
                                .system(
                                    size: 9,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(MontamPalette.black)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(MontamPalette.gold)
                            .clipShape(MontamCutRectangle(cut: 5))
                    }

                    ProgressView(value: expRatio)
                        .progressViewStyle(.linear)
                        .tint(MontamPalette.gold)
                        .scaleEffect(x: 1, y: 1.08, anchor: .center)
                }

                Spacer(minLength: 8)

                montamLiquidPill
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    resourceCell(
                        title: "montamCoins",
                        value: montamCoins.montamCoins,
                        icon: rewardIcons.montamCoins,
                        tint: MontamPalette.gold
                    )

                    resourceCell(
                        title: "montamSaphirs",
                        value: montamSaphirs.montamSaphirs,
                        icon: rewardIcons.montamSaphirs,
                        tint: MontamPalette.cyan
                    )

                    resourceCell(
                        title: "montamRubys",
                        value: montamRubys.montamRubys,
                        icon: rewardIcons.montamRubys,
                        tint: MontamPalette.crimson
                    )

                    resourceCell(
                        title: "montamShards",
                        value: montamShards.montamShards,
                        icon: rewardIcons.montamShards,
                        tint: MontamPalette.violet
                    )

                    resourceCell(
                        title: "montamContainers",
                        value: montamContainers.tokens,
                        icon: rewardIcons.montamContainers,
                        tint: MontamPalette.emerald
                    )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)

    }

    private var montamLiquidPill: some View {
        HStack(spacing: 5) {
            RemoteAssetImage(name: rewardIcons.montamLiquid)
                .scaledToFit()
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text("montamLiquid")
                    .font(.system(size: 7, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.amber)

                Text("\(montamLiquid.montamLiquid)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .background(MontamPalette.black.opacity(0.82))
        .clipShape(MontamCutRectangle(cut: 8))
        .overlay(
            MontamCutRectangle(cut: 8)
                .stroke(MontamPalette.blue, lineWidth: 1.4)
        )
    }

    private func resourceCell(
        title: String,
        value: Int,
        icon: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 5) {
            RemoteAssetImage(name: icon)
                .scaledToFit()
                .frame(width: 17, height: 17)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 6.5, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)

                Text("\(value)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(width: 128, height: 30)
        .background(MontamPalette.black.opacity(0.75))
        .clipShape(MontamCutRectangle(cut: 8))
        .overlay(
            MontamCutRectangle(cut: 8)
                .stroke(tint.opacity(0.85), lineWidth: 1)
        )
    }
}

private struct GlobalGameFooter: View {
    @Binding var selectedTab: RootView.Tab

    private var items: [FooterItem] {
        let configItems =
            GameConfigManager.shared.config.footerItems
            ?? GameFooterConfigItem.fallback

        return configItems.compactMap { item in
            guard let tab = RootView.Tab(rawValue: item.tab) else {
                return nil
            }

            return FooterItem(
                tab: tab,
                title: item.title,
                icon: item.icon,
                systemIcon: footerSystemIcon(for: tab),
                tint: footerTint(for: item.color)
            )
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                Button {
                    selectedTab = item.tab
                } label: {
                    footerItem(item)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func footerItem(_ item: FooterItem) -> some View {
        let isSelected = selectedTab == item.tab

        return VStack(spacing: 3) {
            footerIcon(item, isSelected: isSelected)

            Text(item.title)
                .font(.system(size: 8.5, weight: .black, design: .rounded))
                .foregroundStyle(
                    isSelected ? .white : MontamPalette.mutedText
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(
            AnyShapeStyle(
                LinearGradient(
                    colors: footerFillColors(
                        item: item,
                        isSelected: isSelected
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        )
        .clipShape(MontamCutRectangle(cut: 11))
        .overlay(
            MontamCutRectangle(cut: 11)
                .stroke(
                    isSelected ? MontamPalette.gold : item.tint.opacity(0.58),
                    lineWidth: isSelected ? 2 : 1.2
                )
        )
        .scaleEffect(isSelected ? 1.04 : 1)
        .animation(.easeOut(duration: 0.16), value: isSelected)
        .offset(y: isSelected ? -3 : 0)
    }

    private func footerFillColors(
        item: FooterItem,
        isSelected: Bool
    ) -> [Color] {
        if isSelected {
            return [
                item.tint,
                MontamPalette.black,
                MontamPalette.black,
            ]
        }

        return [
            item.tint,
            MontamPalette.black,
            MontamPalette.black,
        ]
    }
}

private struct ChromePanelBackground: View {
    let cut: CGFloat

    var body: some View {
        LinearGradient(
            colors: [
                MontamPalette.black.opacity(0.46),
                MontamPalette.blue.opacity(0.20),
                MontamPalette.black.opacity(0.40),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .trailing) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 94, height: 94)
                .opacity(0.07)
                .offset(x: 26)
        }
        .clipShape(MontamCutRectangle(cut: cut))
    }
}

private struct FooterItem: Identifiable {
    let tab: RootView.Tab
    let title: String
    let icon: String
    let systemIcon: String
    let tint: Color

    var id: RootView.Tab { tab }
}

extension GlobalGameFooter {
    fileprivate func footerIcon(_ item: FooterItem, isSelected: Bool)
        -> some View
    {
        Group {
            if RemoteAssetManager.shared.localURL(for: item.icon) != nil {
                RemoteAssetImage(name: item.icon)
                    .scaledToFit()
            } else {
                Image(systemName: item.systemIcon)
                    .font(
                        .system(
                            size: isSelected ? 21 : 19,
                            weight: .black
                        )
                    )
                    .foregroundStyle(
                        isSelected ? item.tint : .white.opacity(0.72)
                    )
            }
        }
        .frame(
            width: isSelected ? 28 : 24,
            height: isSelected ? 28 : 24
        )
        .shadow(
            color: isSelected ? item.tint.opacity(0.45) : .clear,
            radius: 8
        )
    }
}

private func footerSystemIcon(for tab: RootView.Tab) -> String {
    switch tab {
    case .home:
        return "house.fill"
    case .team:
        return "person.3.fill"
    case .summon:
        return "sparkles"
    case .shop:
        return "bag.fill"
    case .exchange:
        return "arrow.left.arrow.right"
    case .upgrade:
        return "star.circle.fill"
    }
}

private func footerTint(for color: String?) -> Color {
    switch color?.lowercased() {
    case "gold", "yellow":
        return MontamPalette.gold
    case "cyan":
        return MontamPalette.cyan
    case "violet", "purple":
        return MontamPalette.violet
    case "emerald", "green":
        return MontamPalette.emerald
    case "crimson", "red":
        return MontamPalette.crimson
    case "blue":
        return MontamPalette.blue
    default:
        return MontamPalette.gold
    }
}

#Preview {
    GameLayout(selectedTab: .constant(.home)) {
        Text("Montam Preview")
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(.white)
    }
}
