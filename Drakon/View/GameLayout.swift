//
//  GameLayout.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
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
        ZStack {
            DrakonScreenBackground()

            VStack(spacing: 10) {
                GlobalGameHeader()
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

                content

                    .id(selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                GlobalGameFooter(selectedTab: $selectedTab)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

private struct GlobalGameHeader: View {
    @ObservedObject private var coins = CoinManager.shared
    @ObservedObject private var gems = GemManager.shared
    @ObservedObject private var rubies = RubyManager.shared
    @ObservedObject private var eventCurrency = EventCurrencyManager.shared
    @ObservedObject private var draken = DrakenManager.shared
    @ObservedObject private var shards = ShardManager.shared
    @ObservedObject private var progress = PlayerProgressManager.shared

    private var rank: Int {
        max(1, ((progress.level - 1) / 10) + 1)
    }

    private var expRatio: Double {
        guard progress.requiredEXP > 0 else { return 0 }
        return min(1, Double(progress.exp) / Double(progress.requiredEXP))
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                RemoteAssetImage(name: "drakon_icon")
                    .scaledToFit()
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("LV \(progress.level)")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)

                        Text("RANK \(rank)")
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(DrakonBladePalette.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DrakonBladePalette.gold)
                            .clipShape(
                                DrakonBladeShape(pointDepth: 8, slant: 5)
                            )
                    }

                    ProgressView(value: expRatio)
                        .progressViewStyle(.linear)
                        .tint(DrakonBladePalette.gold)
                        .scaleEffect(x: 1, y: 1.35, anchor: .center)
                }

                Spacer(minLength: 8)

                drakenPill
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 8
            ) {
                resourceCell(
                    title: "COINS",
                    value: coins.coins,
                    icon: "icon_drakon_coin",
                    tint: DrakonBladePalette.gold
                )

                resourceCell(
                    title: "GEMS",
                    value: gems.gems,
                    icon: "icon_drakon_gem",
                    tint: DrakonBladePalette.cyan
                )

                resourceCell(
                    title: "RUBY",
                    value: rubies.rubies,
                    icon: "icon_drakon_ruby",
                    tint: DrakonBladePalette.crimson
                )

                resourceCell(
                    title: "SHARDS",
                    value: shards.shards,
                    icon: "icon_drakon_shard",
                    tint: DrakonBladePalette.violet
                )

                resourceCell(
                    title: "EVENT",
                    value: eventCurrency.tokens,
                    icon: "icon_draken_container",
                    tint: DrakonBladePalette.emerald
                )
            }
        }
        .padding(12)
        .background(
            DrakonBladePalette.panel.opacity(0.96)
                .overlay(alignment: .trailing) {
                    RemoteAssetImage(name: "drakon_icon")
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .opacity(0.07)
                        .offset(x: 34)
                }
        )
        .clipShape(DrakonCutRectangle(cut: 18))
        .overlay(
            DrakonCutRectangle(cut: 18)
                .stroke(
                    LinearGradient(
                        colors: [
                            DrakonBladePalette.gold, DrakonBladePalette.blue,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
    }

    private var drakenPill: some View {
        HStack(spacing: 7) {
            RemoteAssetImage(name: "icon_draken")
                .scaledToFit()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text("DRAKEN")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.amber)

                Text("\(draken.draken)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 42)
        .background(DrakonBladePalette.black.opacity(0.82))
        .clipShape(DrakonBladeShape(pointDepth: 12, slant: 8))
        .overlay(
            DrakonBladeShape(pointDepth: 12, slant: 8)
                .stroke(DrakonBladePalette.blue, lineWidth: 1.4)
        )
    }

    private func resourceCell(
        title: String,
        value: Int,
        icon: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 7) {
            RemoteAssetImage(name: icon)
                .scaledToFit()
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)

                Text("\(value)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .frame(height: 38)
        .background(DrakonBladePalette.black.opacity(0.75))
        .clipShape(DrakonBladeShape(pointDepth: 11, slant: 7))
        .overlay(
            DrakonBladeShape(pointDepth: 11, slant: 7)
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
        HStack(spacing: 7) {
            ForEach(items) { item in
                Button {
                    selectedTab = item.tab
                } label: {
                    footerItem(item)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(DrakonBladePalette.panel.opacity(0.96))
        .clipShape(DrakonCutRectangle(cut: 16))
        .overlay(
            DrakonCutRectangle(cut: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            DrakonBladePalette.gold, DrakonBladePalette.blue,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
        )
    }

    private func footerItem(_ item: FooterItem) -> some View {
        let isSelected = selectedTab == item.tab

        return VStack(spacing: 5) {
            footerIcon(item, isSelected: isSelected)

            Text(item.title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(
                    isSelected ? .white : DrakonBladePalette.mutedText
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 72)
        .background(
            isSelected
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [
                            item.tint.opacity(0.34),
                            item.tint.opacity(0.14),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyShapeStyle(Color.clear)
        )
        .clipShape(DrakonBladeShape(pointDepth: 12, slant: 8))
        .overlay(
            DrakonBladeShape(pointDepth: 12, slant: 8)
                .stroke(
                    isSelected
                        ? item.tint
                        : .white.opacity(0.08),
                    lineWidth: isSelected ? 2.2 : 1
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1)
        .animation(.easeOut(duration: 0.16), value: isSelected)
        .offset(y: -2)
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
                            size: isSelected ? 25 : 22,
                            weight: .black
                        )
                    )
                    .foregroundStyle(
                        isSelected ? item.tint : .white.opacity(0.72)
                    )
            }
        }
        .frame(
            width: isSelected ? 38 : 32,
            height: isSelected ? 38 : 32
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
        return DrakonBladePalette.gold
    case "cyan":
        return DrakonBladePalette.cyan
    case "violet", "purple":
        return DrakonBladePalette.violet
    case "emerald", "green":
        return DrakonBladePalette.emerald
    case "crimson", "red":
        return DrakonBladePalette.crimson
    case "blue":
        return DrakonBladePalette.blue
    default:
        return DrakonBladePalette.gold
    }
}
