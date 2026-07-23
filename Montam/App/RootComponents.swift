//
//  RootComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

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

    var iconName: String {
        switch self {
        case .tamer: "tamer"
        case .montam: "montam"
        case .dungeon: "dungeon"
        case .game: "game"
        case .summon: "summon"
        case .shop: "shop"
        case .trade: "trade"
        }
    }
}

struct RootGameHeader: View {
    var body: some View {
        PlayerStatusBar()
            .padding(.top)
            .offset(y: 20)
    }
}

struct RootQuickMenuButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(action: action) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.cyan)
                        .frame(width: 46, height: 46)
                        .background(.black.opacity(0.42))
                        .clipShape(RoundedRectangle(cornerRadius: 13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13).stroke(
                                .cyan.opacity(0.68),
                                lineWidth: 2
                            )
                        )
                        .shadow(color: .black.opacity(0.35), radius: 5)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, 96)
            }
        }
        .ignoresSafeArea()
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
            Spacer()

            VStack(spacing: 12) {
                HStack {
                    Text("Menü")
                        .font(
                            .system(size: 22, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(.cyan)
                            .frame(width: 30, height: 30)
                            .background(.black.opacity(0.28))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
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
            .frame(maxWidth: 340)
            .background(RootChromeBackground())
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18).stroke(
                    .cyan.opacity(0.6),
                    lineWidth: 2
                )
            )
            .shadow(color: .black.opacity(0.48), radius: 14, y: 8)
            .padding(.horizontal, 18)
            .padding(.bottom, 106)
        }
        .ignoresSafeArea()
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
            .frame(height: 46)
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

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(RootTab.allCases) { tab in
                    RootFooterButton(tab: tab, isSelected: selectedTab == tab) {
                        selectedTab = tab
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding()
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
        case .game: 50
        case .dungeon, .summon: 30
        default: 30
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                GeneratedTabIcon(id: tab.iconName, isSelected: isSelected)
                    .padding(tab == .game ? 10 : 8)
                    .frame(width: iconSize, height: iconSize)
                    .background(tileBackground)
                    .clipShape(
                        RoundedRectangle(cornerRadius: tab == .game ? 42 : 11)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: tab == .game ? 42 : 11)
                            .stroke(
                                isSelected
                                    ? .white.opacity(0.78) : .cyan.opacity(0.6),
                                lineWidth: 2
                            )
                    )
                    .shadow(
                        color: tab == .game
                            ? .purple.opacity(0.85) : .black.opacity(0.45),
                        radius: tab == .game ? 12 : 3
                    )

                if !tab.title.isEmpty {
                    Text(tab.title)
                        .font(
                            .system(size: 6, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(isSelected ? .white : .cyan)
                }
            }
        }
        .padding(.bottom, 8)
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

#Preview {
    RootView()
}
