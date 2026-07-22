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
            .padding(.horizontal)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottom
            )
            .background(AppScreenBackground())
    }
}

struct RootTopActionButtons: View {
    let onDailyTap: () -> Void
    let onGiftTap: () -> Void
    let onNewsTap: () -> Void
    let onSettingsTap: () -> Void

    private let columns = [
        GridItem(.fixed(32), spacing: 6),
        GridItem(.fixed(32), spacing: 6),
    ]

    var body: some View {
        VStack {
            HStack {
                Spacer()

                LazyVGrid(columns: columns, spacing: 6) {
                    RootTopActionButton(
                        systemName: "calendar",
                        action: onDailyTap
                    )

                    RootTopActionButton(
                        systemName: "gift.fill",
                        action: onGiftTap
                    )

                    RootTopActionButton(
                        systemName: "newspaper.fill",
                        action: onNewsTap
                    )

                    RootTopActionButton(
                        systemName: "gear",
                        action: onSettingsTap
                    )
                }
                .frame(width: 70)
            }
            .padding(.horizontal)
            .padding(.top, 100)

            Spacer()
        }
        .ignoresSafeArea()
    }
}

private struct RootTopActionButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.cyan)
                .frame(width: 32, height: 32)
                .background(Color.black.opacity(0.34))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(
                        .cyan.opacity(0.5),
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
            AppScreenBackground()

            VStack(spacing: 2) {
                RootFooterWave()
                    .fill(.blue.opacity(0.72))
                    .overlay(
                        RootFooterWave().stroke(
                            .cyan.opacity(0.72),
                            lineWidth: 2
                        )
                    )

                RootLinePattern()
                    .opacity(0.65)
            }

            HStack(alignment: .bottom, spacing: 0) {
                ForEach(RootTab.allCases) { tab in
                    RootFooterButton(tab: tab, isSelected: selectedTab == tab) {
                        selectedTab = tab
                    }
                    .padding(.horizontal, 5)
                }
            }
            .padding(.bottom, 22)
        }
    }
}

private struct RootFooterButton: View {
    let tab: RootTab
    let isSelected: Bool
    let action: () -> Void

    private var offsetY: CGFloat {
        switch tab {
        case .tamer: 6
        case .montam: 9
        case .dungeon: 12
        case .game: 20
        case .summon: 12
        case .shop: 9
        case .trade: 6
        }
    }

    private var iconSize: CGFloat {
        switch tab {
        case .game: 58
        case .dungeon, .summon: 34
        default: 34
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
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(isSelected ? .white : .cyan)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                }
            }
            .frame(width: iconSize, height: iconSize)
        }
        .offset(y: offsetY)
        .padding(.bottom, 20)
    }

    private var tileBackground: some ShapeStyle {
        if tab == .game {
            return AnyShapeStyle(
                RadialGradient(
                    colors: [
                        .cyan.opacity(0.95), .blue.opacity(0.78), .indigo,
                    ],
                    center: .center,
                    startRadius: 8,
                    endRadius: 44
                )
            )
        }

        if tab == .shop && isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.white, .yellow.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
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

private struct RootLinePattern: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<28, id: \.self) { _ in
                Rectangle()
                    .fill(.cyan.opacity(0.35))
                    .frame(height: 1)
            }
        }
    }
}

private struct RootFooterWave: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.18))
            path.addQuadCurve(
                to: CGPoint(x: rect.width * 0.34, y: rect.height * 0.38),
                control: CGPoint(x: rect.width * 0.18, y: rect.height * 0.8)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.width * 0.66, y: rect.height * 0.38),
                control: CGPoint(x: rect.width * 0.5, y: rect.minY)
            )
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.height * 0.18),
                control: CGPoint(x: rect.width * 0.82, y: rect.height * 0.8)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

#Preview {
    RootView()
}
