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

    init(navigate: @escaping (RootView.HomeRoute) -> Void = { _ in }) {
        self.navigate = navigate
    }

    private let black = MontamPalette.black
    private let panel = MontamPalette.panel
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Spacer(minLength: 2)

                VStack(spacing: 7) {
                    ForEach(menuItems) { item in
                        if item.style == "wide" {
                            Button {
                                perform(item)
                            } label: {
                                eggLink(
                                    title: item.title,
                                    image: item.icon,
                                    tint: menuTint(for: item.color)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 9),
                            GridItem(.flexible(), spacing: 9),
                        ],
                        spacing: 7
                    ) {
                        ForEach(menuItems.filter { $0.style != "wide" }) {
                            item in
                            Button {
                                perform(item)
                            } label: {
                                smallEggLink(
                                    title: item.title,
                                    image: item.icon,
                                    tint: menuTint(for: item.color)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(menuBackground)
    }

    private var menuBackground: some View {
        LinearGradient(
            colors: [
                black,
                Color(red: 0.018, green: 0.038, blue: 0.082),
                black,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
            .overlay(alignment: .topTrailing) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .opacity(0.055)
                    .offset(x: 54, y: -34)
            }
            .overlay(alignment: .bottomLeading) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .opacity(0.045)
                    .offset(x: -80, y: 72)
            }
            .ignoresSafeArea()
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

    private func eggLink(title: String, image: String, tint: Color)
        -> some View
    {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(matteFill(tint: tint))
                .overlay(
                    Capsule()
                        .stroke(tint.opacity(0.88), lineWidth: 1.6)
                )
                .shadow(color: tint.opacity(0.16), radius: 10, y: 4)

            HStack(spacing: 11) {
                iconEgg(image: image, tint: tint, size: 40)

                Text(title)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer()
            }
            .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }

    private func smallEggLink(title: String, image: String, tint: Color)
        -> some View
    {
        VStack(spacing: 4) {
            iconEgg(image: image, tint: tint, size: 42)

            Text(title.uppercased())
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(matteFill(tint: tint))
        .overlay(
            MontamEggShape()
                .stroke(tint.opacity(0.90), lineWidth: 1.7)
        )
        .clipShape(MontamEggShape())
        .shadow(color: tint.opacity(0.14), radius: 8, y: 4)
    }

    private func iconEgg(image: String, tint: Color, size: CGFloat) -> some View {
        RemoteAssetImage(name: image)
            .scaledToFit()
            .padding(size * 0.16)
            .frame(width: size, height: size)
            .background(
                MontamEggShape()
                    .fill(MontamPalette.black.opacity(0.58))
            )
            .overlay(
                MontamEggShape()
                    .stroke(tint.opacity(0.75), lineWidth: 1.2)
            )
    }

    private func matteFill(tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                panel.opacity(0.98),
                tint.opacity(0.18),
                MontamPalette.black.opacity(0.88),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    MenuView()
        .environmentObject(AppModel())
}
