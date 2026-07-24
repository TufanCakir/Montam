//
//  RootComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

enum RootLayoutMetrics {
    static let headerHeight: CGFloat = 82
    static let footerHeight: CGFloat = 108
    static let screenInset: CGFloat = 16
    static let chromeOpacity = 0.82

    static let quickButtonSize: CGFloat = 46
    static let quickButtonTopPadding: CGFloat = headerHeight + 20

    static let quickMenuMaxWidth: CGFloat = 340
    static let quickMenuBottomPadding: CGFloat = footerHeight + 20
    static let quickMenuItemHeight: CGFloat = 46

    static let footerIconSize: CGFloat = 30
    static let footerGameIconSize: CGFloat = 50
    static let footerItemWidth: CGFloat = 44
}

enum RootTab: CaseIterable, Identifiable {
    case tamer
    case montam
    case dungeon
    case game
    case summon
    case shop
    case trade

    var id: Self { self }

    var title: String {
        switch self {
        case .tamer: "Tamer"
        case .montam: "Montam"
        case .dungeon: "Dungeon"
        case .game: ""
        case .summon: "Summon"
        case .shop: "Shop"
        case .trade: "Trade"
        }
    }

    var systemImageName: String {
        switch self {
        case .tamer: "person.crop.circle.fill"
        case .montam: "pawprint.fill"
        case .dungeon: "door.left.hand.open"
        case .game: "globe.europe.africa.fill"
        case .summon: "sparkles"
        case .shop: "storefront.fill"
        case .trade: "arrow.left.arrow.right.circle.fill"
        }
    }
}

struct RootGameHeader: View {
    let status: PlayerStatusBarState

    var body: some View {
        VStack {
            Spacer()

            PlayerStatusBar(state: status)
        }

    }
}

struct RootQuickMenuButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button(action: action) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.cyan)
                        .frame(
                            width: RootLayoutMetrics.quickButtonSize,
                            height: RootLayoutMetrics.quickButtonSize
                        )
                        .rootIconSurface(cornerRadius: 13)
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(.top, RootLayoutMetrics.quickButtonTopPadding)
        .padding(.trailing, RootLayoutMetrics.screenInset)

    }
}

struct RootQuickMenuPanel: View {
    let onDailyTap: () -> Void
    let onGiftTap: () -> Void
    let onNewsTap: () -> Void
    let onMissionTap: () -> Void
    let onSettingsTap: () -> Void
    let onClose: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        VStack {
            Spacer(minLength: 0)

            VStack(spacing: 10) {
                HStack {
                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.cyan)
                            .frame(width: 30, height: 30)
                            .rootIconSurface(cornerRadius: 8)
                    }
                    .buttonStyle(.plain)
                }

                LazyVGrid(columns: columns, spacing: 10) {
                    RootQuickMenuItem(
                        title: "Daily",
                        systemName: "calendar",
                        action: onDailyTap
                    )

                    RootQuickMenuItem(
                        title: "Geschenke",
                        systemName: "gift.fill",
                        action: onGiftTap
                    )

                    RootQuickMenuItem(
                        title: "News",
                        systemName: "newspaper.fill",
                        action: onNewsTap
                    )

                    RootQuickMenuItem(
                        title: "Mission",
                        systemName: "list.bullet.rectangle.fill",
                        action: onMissionTap
                    )

                    RootQuickMenuItem(
                        title: "Optionen",
                        systemName: "gear",
                        action: onSettingsTap
                    )
                }
            }
            .padding(14)
            .frame(maxWidth: RootLayoutMetrics.quickMenuMaxWidth)
            .rootPanelSurface(cornerRadius: 18)
            .padding(.horizontal, RootLayoutMetrics.screenInset)
            .padding(.bottom, RootLayoutMetrics.quickMenuBottomPadding)
        }
    }
}

private struct RootQuickMenuItem: View {
    let title: String
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(.cyan)
                    .frame(width: 26, height: 26)

                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .frame(height: RootLayoutMetrics.quickMenuItemHeight)
            .background(.blue.opacity(0.36))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(
                    .cyan.opacity(0.35),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(.plain)
    }
}

struct RootGameFooter: View {
    @Binding var selectedTab: RootTab

    var body: some View {
        ZStack(alignment: .bottom) {
            RootChromeBackground()

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(RootTab.allCases) { tab in
                    RootFooterButton(tab: tab, isSelected: selectedTab == tab) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, RootLayoutMetrics.screenInset)
            .padding(.bottom, 26)
        }
    }
}

private struct RootChromeBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0, green: 0.05, blue: 0.18),
                Color(red: 0, green: 0.12, blue: 0.34),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private struct RootFooterButton: View {
    let tab: RootTab
    let isSelected: Bool
    let action: () -> Void

    private var offsetY: CGFloat {
        switch tab {
        case .tamer: 3
        case .montam: 5
        case .dungeon: 7
        case .game: 13
        case .summon: 7
        case .shop: 5
        case .trade: 3
        }
    }

    private var iconSize: CGFloat {
        switch tab {
        case .game:
            RootLayoutMetrics.footerGameIconSize
        case .dungeon, .summon:
            RootLayoutMetrics.footerIconSize
        default:
            RootLayoutMetrics.footerIconSize
        }
    }

    private var cornerRadius: CGFloat {
        tab == .game ? 25 : 11
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.systemImageName)
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? .white : .cyan)
                    .padding(tab == .game ? 10 : 8)
                    .frame(width: iconSize, height: iconSize)
                    .background(tileBackground)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                isSelected
                                    ? .white.opacity(0.78) : .cyan.opacity(0.6),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: tab == .game
                            ? .purple.opacity(0.65) : .black.opacity(0.35),
                        radius: tab == .game ? 8 : 3
                    )

                Text(tab.title)
                    .font(.system(size: 6, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? .white : .cyan)
                    .frame(height: 8)
                    .opacity(tab.title.isEmpty ? 0 : 1)
            }
            .frame(width: RootLayoutMetrics.footerItemWidth)
        }
        .buttonStyle(.plain)
        .offset(y: offsetY)
    }

    private var tileBackground: some ShapeStyle {
        if tab == .game {
            return AnyShapeStyle(
                RadialGradient(
                    colors: [
                        .blue.opacity(0.95), .blue.opacity(0.78), .indigo,
                    ],
                    center: .center,
                    startRadius: 8,
                    endRadius: 44
                )
            )
        }

        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.blue.opacity(isSelected ? 0.96 : 0.78),
                    Color.blue.opacity(0.48),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

private extension View {
    func rootIconSurface(cornerRadius: CGFloat) -> some View {
        background(.black.opacity(0.34))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.cyan.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 4)
    }

    func rootPanelSurface(cornerRadius: CGFloat) -> some View {
        background(RootChromeBackground())
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.cyan.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.42), radius: 12, y: 6)
    }
}

#Preview {
    RootView()
}
