//
//  MenuView.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var appModel: AppModel
    let navigate: (RootView.HomeRoute) -> Void

    init(navigate: @escaping (RootView.HomeRoute) -> Void = { _ in }) {
        self.navigate = navigate
    }

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Spacer(minLength: 4)

                VStack(spacing: 9) {
                    ForEach(menuItems) { item in
                        if item.style == "wide" {
                            Button {
                                perform(item)
                            } label: {
                                bladeLink(
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
                        spacing: 9
                    ) {
                        ForEach(menuItems.filter { $0.style != "wide" }) {
                            item in
                            Button {
                                perform(item)
                            } label: {
                                smallBladeLink(
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
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(menuBackground)
    }

    private var menuBackground: some View {
        black
            .overlay(alignment: .topTrailing) {
                RemoteAssetImage(name: "drakon_icon")
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .opacity(0.055)
                    .offset(x: 54, y: -34)
            }
            .overlay(alignment: .bottomLeading) {
                RemoteAssetImage(name: "drakon_icon")
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
            return DrakonBladePalette.cyan
        case "violet", "purple":
            return DrakonBladePalette.violet
        case "emerald", "green":
            return DrakonBladePalette.emerald
        case "crimson", "red":
            return DrakonBladePalette.crimson
        default:
            return gold
        }
    }

    private func menuButton(
        title: String,
        image: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                BladeMenuShape(pointDepth: 34, slant: 16)
                    .fill(panel)
                    .overlay(
                        BladeMenuShape(pointDepth: 34, slant: 16)
                            .stroke(tint, lineWidth: 2)
                    )

                HStack(spacing: 16) {
                    RemoteAssetImage(name: image)
                        .scaledToFit()
                        .frame(width: 48, height: 48)

                    Text(title.uppercased())
                        .font(
                            .system(size: 17, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer()

                    RemoteAssetImage(name: "skin_solarion_imperial_default")
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .opacity(0.82)
                        .padding(.trailing, 18)
                }
                .padding(.leading, 18)
                .padding(.trailing, 28)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 66)
        }
        .buttonStyle(.plain)
    }

    private func smallMenuButton(
        title: String,
        image: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RemoteAssetImage(name: image)
                    .scaledToFit()
                    .frame(width: 52, height: 52)

                Text(title.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(panel)
            .overlay(
                AngledMenuRectangle(cut: 16)
                    .stroke(tint, lineWidth: 2)
            )
            .clipShape(AngledMenuRectangle(cut: 16))
        }
        .buttonStyle(.plain)
    }

    private func bladeLink(title: String, image: String, tint: Color)
        -> some View
    {
        ZStack(alignment: .leading) {
            BladeMenuShape(pointDepth: 28, slant: 12)
                .fill(panel)
                .overlay(
                    BladeMenuShape(pointDepth: 28, slant: 12)
                        .stroke(tint, lineWidth: 1.8)
                )

            HStack(spacing: 14) {
                RemoteAssetImage(name: image)
                    .scaledToFit()
                    .frame(width: 42, height: 42)

                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()
            }
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
    }

    private func smallBladeLink(title: String, image: String, tint: Color)
        -> some View
    {
        VStack(spacing: 6) {
            RemoteAssetImage(name: image)
                .scaledToFit()
                .frame(width: 44, height: 44)

            Text(title.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 82)
        .background(panel)
        .overlay(
            AngledMenuRectangle(cut: 14)
                .stroke(tint, lineWidth: 1.8)
        )
        .clipShape(AngledMenuRectangle(cut: 14))
    }
}

private struct BladeMenuShape: Shape {
    let pointDepth: CGFloat
    let slant: CGFloat

    func path(in rect: CGRect) -> Path {
        let pointDepth = min(pointDepth, rect.width * 0.22)
        let slant = min(slant, rect.height * 0.38)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct AngledMenuRectangle: Shape {
    let cut: CGFloat

    func path(in rect: CGRect) -> Path {
        let cut = min(cut, min(rect.width, rect.height) / 2)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        path.closeSubpath()
        return path
    }
}

#Preview {
    MenuView()
        .environmentObject(AppModel())
}
