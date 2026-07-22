//
//  GeneratedGameVisuals.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import SwiftUI

struct GameResourceIcon: View {
    let id: String
    let fallbackImage: String?

    @State private var pulse = false

    var body: some View {
        iconBody
            .scaleEffect(resource?.animation == "pulse" && pulse ? 1.08 : 1)
            .shadow(color: primaryColor.opacity(resource?.glow == true ? 0.85 : 0), radius: resource?.glow == true ? 7 : 0)
            .task {
                guard resource?.animation == "pulse" else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }

    @ViewBuilder
    private var iconBody: some View {
        if resource?.renderMode == .image, let imageName = resource?.imageName ?? fallbackImage {
            Image(imageName)
                .resizable()
                .scaledToFit()
        } else {
            generatedIcon
        }
    }

    @ViewBuilder
    private var generatedIcon: some View {
        switch resource?.shape ?? id {
        case "coin":
            GeneratedCoinIcon(colors: colors)
        case "crystal":
            GeneratedCrystalIcon(colors: colors)
        case "ticket":
            GeneratedTicketIcon(colors: colors)
        case "exp":
            GeneratedExpIcon(colors: colors)
        default:
            GeneratedCrystalIcon(colors: colors)
        }
    }

    private var resource: GameVisualResourceData? {
        GameVisualCatalog.shared.resource(id: id)
    }

    private var colors: [Color] {
        let hexColors = resource?.colors ?? []
        let resolved = hexColors.compactMap { Color(hex: $0) }
        return resolved.isEmpty ? [.cyan, .blue] : resolved
    }

    private var primaryColor: Color {
        colors.first ?? .cyan
    }
}

struct GeneratedTabIcon: View {
    let id: String
    let isSelected: Bool

    var body: some View {
        ZStack {
            switch id {
            case "tamer":
                Circle()
                    .stroke(lineWidth: 4)
                    .overlay(Circle().fill(.cyan.opacity(0.18)).padding(8))
                    .overlay(Capsule().fill(.cyan).frame(width: 28, height: 9).offset(y: 13))
                    .overlay(Circle().fill(.cyan).frame(width: 22, height: 22).offset(y: -6))
            case "montam":
                PixelMonsterShape()
                    .fill(.cyan)
                    .overlay(PixelMonsterShape().stroke(.white.opacity(0.35), lineWidth: 2))
            case "dungeon":
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.cyan, lineWidth: 5)
                    .overlay(Rectangle().fill(.cyan).frame(width: 4).offset(x: -7))
                    .overlay(Circle().fill(.cyan).frame(width: 5, height: 5).offset(x: 9))
                    .padding(9)
            case "game":
                Circle()
                    .stroke(.cyan.opacity(0.95), lineWidth: 5)
                    .overlay(Circle().stroke(.white.opacity(0.32), lineWidth: 11).padding(4))
                    .overlay(Capsule().stroke(.cyan, lineWidth: 3).frame(width: 42, height: 18))
                    .overlay(Capsule().stroke(.cyan, lineWidth: 3).frame(width: 18, height: 42))
            case "summon":
                SparkShape(points: 8)
                    .fill(.cyan)
                    .overlay(SparkShape(points: 8).stroke(.white.opacity(0.42), lineWidth: 2))
                    .padding(7)
            case "explore":
                RoundedRectangle(cornerRadius: 7)
                    .fill(.cyan)
                    .overlay(SparkShape(points: 5).fill(.blue).padding(14))
                    .rotationEffect(.degrees(-8))
                    .padding(8)
            case "shop":
                StorefrontShape()
                    .fill(isSelected ? .blue : .cyan)
                    .overlay(StorefrontShape().stroke(.white.opacity(0.35), lineWidth: 2))
                    .padding(5)
            default:
                Circle().fill(.cyan)
            }
        }
    }
}

struct GeneratedHeaderTownBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.pink.opacity(0.62), .purple.opacity(0.38), .cyan.opacity(0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(alignment: .bottom, spacing: -10) {
                ForEach(0..<8, id: \.self) { index in
                    GeneratedHouse()
                        .frame(width: 108, height: CGFloat(94 + index % 3 * 28))
                        .opacity(0.62)
                }
            }
            .offset(y: 20)

            ForEach(0..<20, id: \.self) { index in
                Capsule()
                    .fill([Color.pink, .yellow, .cyan, .orange][index % 4].opacity(0.68))
                    .frame(width: 4, height: CGFloat(16 + index % 4 * 8))
                    .rotationEffect(.degrees(Double(index * 29)))
                    .offset(x: CGFloat((index * 47) % 430) - 215, y: CGFloat((index * 31) % 110) - 55)
            }
        }
    }
}

private struct GameVisualCatalog {
    static let shared = GameVisualCatalog()

    private let resources: [GameVisualResourceData]

    init() {
        guard
            let url = Bundle.main.url(forResource: "gameVisual", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(GameVisualCatalogData.self, from: data)
        else {
            resources = []
            return
        }

        resources = catalog.resources
    }

    func resource(id: String) -> GameVisualResourceData? {
        resources.first { $0.id == id }
    }
}

private struct GeneratedCoinIcon: View {
    let colors: [Color]

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: colors + [.white.opacity(0.4)], center: .topLeading, startRadius: 3, endRadius: 34))
            .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: 3).padding(4))
            .overlay(Circle().stroke(.black.opacity(0.22), lineWidth: 2))
            .overlay(Text("bit").font(.system(size: 9, weight: .black, design: .rounded)).foregroundStyle(.white))
    }
}

private struct GeneratedCrystalIcon: View {
    let colors: [Color]

    var body: some View {
        GemShape()
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(GemShape().stroke(.white.opacity(0.82), lineWidth: 2))
            .overlay(GemFacetShape().stroke(.white.opacity(0.35), lineWidth: 1.4).padding(4))
    }
}

private struct GeneratedTicketIcon: View {
    let colors: [Color]

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.white.opacity(0.78), lineWidth: 2))
            .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: 2).frame(width: 14, height: 14))
            .rotationEffect(.degrees(-12))
    }
}

private struct GeneratedExpIcon: View {
    let colors: [Color]

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: colors, center: .center, startRadius: 2, endRadius: 32))
            .overlay(Circle().stroke(.yellow.opacity(0.8), lineWidth: 3).padding(4))
            .overlay(Text("EXP").font(.system(size: 10, weight: .black, design: .rounded)).foregroundStyle(.yellow))
    }
}

private struct GeneratedHouse: View {
    var body: some View {
        VStack(spacing: 0) {
            TriangleShape()
                .fill(.pink.opacity(0.72))
                .frame(height: 42)
            Rectangle()
                .fill(.cyan.opacity(0.36))
                .overlay {
                    VStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: 10) {
                                Rectangle().fill(.white.opacity(0.52)).frame(width: 14, height: 20)
                                Rectangle().fill(.white.opacity(0.38)).frame(width: 14, height: 20)
                            }
                        }
                    }
                }
        }
    }
}

private struct GemShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.34))
            path.addLine(to: CGPoint(x: rect.width * 0.82, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.34))
            path.closeSubpath()
        }
    }
}

private struct GemFacetShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.34))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.34))
            path.move(to: CGPoint(x: rect.width * 0.18, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.34))
        }
    }
}

private struct SparkShape: Shape {
    let points: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) * 0.48
        let inner = outer * 0.38
        var path = Path()

        for index in 0..<(points * 2) {
            let radius = index.isMultiple(of: 2) ? outer : inner
            let angle = -CGFloat.pi / 2 + CGFloat(index) * .pi / CGFloat(points)
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

private struct PixelMonsterShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let unit = min(rect.width, rect.height) / 6
            let origin = CGPoint(x: rect.midX - unit * 2, y: rect.midY - unit * 2)
            let blocks = [
                CGRect(x: 1, y: 0, width: 2, height: 1),
                CGRect(x: 0, y: 1, width: 4, height: 3),
                CGRect(x: 1, y: 4, width: 1, height: 1),
                CGRect(x: 3, y: 4, width: 1, height: 1),
                CGRect(x: -1, y: 2, width: 1, height: 1),
                CGRect(x: 4, y: 2, width: 1, height: 1)
            ]

            for block in blocks {
                path.addRect(CGRect(
                    x: origin.x + block.minX * unit,
                    y: origin.y + block.minY * unit,
                    width: block.width * unit,
                    height: block.height * unit
                ))
            }
        }
    }
}

private struct StorefrontShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addRoundedRect(in: CGRect(x: rect.minX + rect.width * 0.18, y: rect.height * 0.36, width: rect.width * 0.64, height: rect.height * 0.46), cornerSize: CGSize(width: 4, height: 4))
            path.addRoundedRect(in: CGRect(x: rect.minX + rect.width * 0.12, y: rect.height * 0.18, width: rect.width * 0.76, height: rect.height * 0.2), cornerSize: CGSize(width: 5, height: 5))
            path.addRect(CGRect(x: rect.midX - rect.width * 0.08, y: rect.height * 0.56, width: rect.width * 0.16, height: rect.height * 0.26))
        }
    }
}

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
