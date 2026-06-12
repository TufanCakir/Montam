//
//  MenuView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appModel: AppModel
    let navigate: (RootView.HomeRoute) -> Void
    @State private var showsMenu = false

    init(navigate: @escaping (RootView.HomeRoute) -> Void = { _ in }) {
        self.navigate = navigate
    }

    private let black = MontamPalette.black
    private let panel = MontamPalette.panel
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                featuredMontam(in: proxy.size)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )

                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 82, height: 54)
                    .position(x: 62, y: 64)

                openMenuButton
                    .position(
                        x: max(proxy.size.width - 88, 88),
                        y: max(proxy.size.height - 45, 45)
                    )

                if showsMenu {
                    menuOverlay
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .animation(.easeOut(duration: 0.18), value: showsMenu)
    }

    private func featuredMontam(in size: CGSize) -> some View {
        let imageHeight = min(max(size.height * 0.38, 220), 390)
        let imageWidth = min(size.width * 0.68, 500)

        return RemoteAssetImage(name: homeFeaturedImage)
            .scaledToFill()
            .frame(width: imageWidth, height: imageHeight)
    }

    private var openMenuButton: some View {
        Button {
            showsMenu = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 17, weight: .black))

                Text("MENU")
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(black)
            .padding()
            .background(gold)
            .clipShape(MontamCutRectangle(cut: 12))
            .overlay(
                MontamCutRectangle(cut: 12)
                    .stroke(blue, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 100)
    }

    private var menuOverlay: some View {
        ZStack {
            black.opacity(0.68)
                .ignoresSafeArea()
                .onTapGesture {
                    showsMenu = false
                }

            GeometryReader { proxy in
                VStack {
                    HStack {

                        Spacer()

                        Button {
                            showsMenu = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(MontamPalette.black.opacity(0.78))
                                .clipShape(MontamCutRectangle(cut: 8))
                        }
                        .buttonStyle(.plain)
                    }

                    VStack {
                        LazyVGrid(
                            columns: gridColumns(for: proxy.size.width),
                            spacing: 14
                        ) {
                            ForEach(menuItems) { item in
                                Button {
                                    showsMenu = false
                                    perform(item)
                                } label: {
                                    menuGridButton(item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 6)
                    }
                }
                .padding()
            }
        }
    }

    private var menuItems: [GameMenuConfigItem] {
        GameConfigManager.shared.config.homeMenuItems
            ?? GameMenuConfigItem.fallback
    }

    private func perform(_ item: GameMenuConfigItem) {
        switch item.route {
        case "upgrade":
            appModel.navigateWithLoading {
                appModel.selectedTab = .upgrade
            }
        case "story":
            navigate(.story)
        case "hatchery":
            navigate(.hatchery)
        case "wardrobe":
            navigate(.wardrobe)
        case "events":
            navigate(.events)
        case "gifts":
            navigate(.gifts)
        case "passes":
            navigate(.passes)
        case "news":
            navigate(.news)
        case "settings":
            navigate(.settings)
        default:
            break
        }
    }

    private var homeFeaturedImage: String {
        GameConfigManager.shared.config.homeFeaturedImage
            ?? "skin_imperion_exalted_default"
    }

    private func menuTint(for color: String?) -> Color {
        switch color?.lowercased() {
        case "gold", "yellow":
            return gold
        case "blue":
            return blue
        case "cyan":
            return MontamPalette.cyan
        case "violet", "purple":
            return MontamPalette.violet
        case "emerald", "green":
            return MontamPalette.emerald
        case "crimson", "red":
            return MontamPalette.crimson
        default:
            return gold
        }
    }

    private func menuGridButton(_ item: GameMenuConfigItem) -> some View {
        let tint = menuTint(for: item.color)

        return VStack(spacing: 10) {
            evolutionIcon(image: item.icon, tint: tint, size: 100)

            Text(item.title.uppercased())
                .font(.system(size: 9.5, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .background(menuTileFill(tint: tint))
        .overlay(
            MontamCutRectangle(cut: 13)
                .stroke(tint.opacity(0.90), lineWidth: 1.5)
        )
        .clipShape(MontamCutRectangle(cut: 13))
    }

    private func evolutionIcon(image: String, tint: Color, size: CGFloat)
        -> some View
    {
        RemoteAssetImage(name: image)
            .scaledToFit()
            .padding(size * 0.16)
            .frame(width: size, height: size)
            .background(
                MontamCutRectangle(cut: 9)
                    .fill(MontamPalette.black.opacity(0.58))
            )
            .overlay(
                MontamCutRectangle(cut: 9)
                    .stroke(tint.opacity(0.75), lineWidth: 1.2)
            )
    }

    private func menuTileFill(tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                tint.opacity(0.70),
                panel.opacity(0.96),
                MontamPalette.black.opacity(0.88),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func gridColumns(for width: CGFloat) -> [GridItem] {
        let count = width > 700 ? 4 : 3

        return Array(
            repeating: GridItem(
                .flexible(minimum: 95, maximum: 140),
                spacing: 20
            ),
            count: count
        )
    }
}

#Preview {
    MenuView()
        .environmentObject(AppModel())
}
