//
//  GeneratedEnvironmentViews.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

enum PixelEnvironmentCatalog {
    static func background(id: String) -> BackgroundData {
        let backgrounds =
            JSONDataLoader.load("background", as: [BackgroundData].self) ?? []

        return backgrounds.first { $0.id == id }
            ?? BackgroundData(
                id: id,
                imageName: nil,
                backgroundImage: nil,
                groundImageName: nil,
                groundImage: nil,
                proceduralStyle: "pixel_city_mix",
                skyTopColor: "#071132",
                skyBottomColor: "#2E74D8",
                accentColor: "#21D6FF",
                groundStyle: "pixel_stone",
                groundTopColor: "#26323C",
                groundBottomColor: "#0A1018",
                horizonColor: "#8AE7FF",
                particleStyle: "pixel_confetti",
                yOffset: nil,
                xOffset: nil,
                zOffset: nil
            )
    }

    static func randomBackground() -> BackgroundData {
        let backgrounds =
            JSONDataLoader.load("background", as: [BackgroundData].self) ?? []
        return backgrounds.randomElement()
            ?? background(id: "pixel_start_night_city")
    }
}

struct PixelEnvironmentView: View {
    let data: BackgroundData
    var groundRatio: Double = 0.24

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                GeneratedBackgroundView(data: data)

                GeneratedGroundView(data: data)
                    .frame(height: max(geometry.size.height * groundRatio, 120))
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }
}

struct GeneratedBackgroundView: View {
    let data: BackgroundData

    var body: some View {
        ZStack {
            if let imageName = data.resolvedBackgroundImageName {
                RemoteAssetImage(imageName: imageName)
                    .scaledToFill()
            } else {
                generatedSky
            }

            generatedDetails
        }
        .ignoresSafeArea()
    }

    private var generatedSky: some View {
        LinearGradient(
            colors: [
                Color(hex: data.skyTopColor)
                    ?? Color(red: 0.08, green: 0.18, blue: 0.38),
                Color(hex: data.skyBottomColor)
                    ?? Color(red: 0.54, green: 0.78, blue: 0.95),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private var generatedDetails: some View {
        switch data.proceduralStyle ?? "mountains" {
        case "pixel_night_city", "pixel_night_towers", "pixel_start_night_city":
            PixelNightTowerDetails(
                accent: Color(hex: data.accentColor) ?? .cyan
            )
        case "pixel_rooftop_city", "pixel_skyline", "pixel_city":
            PixelSkylineDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        case "pixel_city_mix":
            PixelCityMixDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        case "pixel_ocean":
            PixelOceanDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        case "pixel_lava":
            PixelLavaSkyDetails(accent: Color(hex: data.accentColor) ?? .orange)
        case "pixel_ice":
            PixelIceSkyDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        case "lava":
            LavaSkyDetails(accent: Color(hex: data.accentColor) ?? .orange)
        case "ice":
            IceSkyDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        case "city":
            CitySkyDetails(accent: Color(hex: data.accentColor) ?? .pink)
        default:
            MountainSkyDetails(accent: Color(hex: data.accentColor) ?? .cyan)
        }
    }
}

struct GeneratedGroundView: View {
    let data: BackgroundData

    var body: some View {
        ZStack {
            if data.resolvedBackgroundImageName != nil {
                Color.clear
            } else if let imageName = data.resolvedGroundImageName {
                RemoteAssetImage(imageName: imageName)
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        Color(hex: data.groundTopColor) ?? .brown.opacity(0.9),
                        Color(hex: data.groundBottomColor)
                            ?? .black.opacity(0.85),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                switch data.groundStyle ?? "stone" {
                case "pixel_lava":
                    PixelLavaGroundDetails()
                case "pixel_ice":
                    PixelIceGroundDetails()
                case "pixel_sand":
                    PixelSandGroundDetails()
                case "pixel_stone":
                    PixelStoneGroundDetails()
                case "lava":
                    LavaGroundDetails()
                case "ice":
                    IceGroundDetails()
                case "sand":
                    SandGroundDetails()
                default:
                    StoneGroundDetails()
                }
            }
        }
        .clipShape(Rectangle())
    }
}

private struct PixelCityMixDetails: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            PixelNightTowerDetails(accent: accent)
                .opacity(0.82)

            PixelSkylineDetails(accent: accent)
                .opacity(0.9)
        }
    }
}

private struct PixelNightTowerDetails: View {
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ForEach(0..<11, id: \.self) { index in
                    let width = CGFloat(
                        [86, 132, 92, 64, 120, 82, 104, 74, 116, 70, 98][index]
                    )
                    let height = CGFloat(
                        [
                            420, 540, 360, 610, 300, 470, 565, 350, 510, 280,
                            390,
                        ][index]
                    )
                    let xOffsets = [-20, 0, 14, -8, 20, -12, 8, 16, -18, 8, 24]
                    let yOffsets = [
                        20, -12, 32, -40, 42, 8, -22, 34, -8, 44, 18,
                    ]

                    PixelTower(index: index, accent: accent)
                        .frame(width: width, height: height)
                        .position(
                            x: CGFloat(index) / 10 * geometry.size.width
                                + CGFloat(xOffsets[index]),
                            y: geometry.size.height - height / 2
                                + CGFloat(yOffsets[index])
                        )
                }

                Rectangle()
                    .fill(Color.black.opacity(0.16))
                    .frame(height: 70)

                PixelParticles(accent: accent)
                    .opacity(0.32)
            }
        }
    }
}

private struct PixelTower: View {
    let index: Int
    let accent: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                Color(red: 0.08, green: 0.11, blue: 0.24).opacity(
                    index.isMultiple(of: 2) ? 0.9 : 0.72
                )
            )
            .overlay {
                VStack(spacing: 18) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 13) {
                            ForEach(0..<3, id: \.self) { column in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(
                                        (row + column + index).isMultiple(of: 3)
                                            ? .yellow.opacity(0.72)
                                            : accent.opacity(0.16)
                                    )
                                    .frame(width: 14, height: 20)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 44)
            }
    }
}

private struct PixelSkylineDetails: View {
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ForEach(0..<12, id: \.self) { index in
                    let width = CGFloat(
                        [72, 118, 88, 62, 134, 82, 112, 76, 124, 68, 96, 104][
                            index
                        ]
                    )
                    let height = CGFloat(
                        [
                            260, 390, 315, 460, 240, 350, 430, 285, 375, 225,
                            330, 405,
                        ][index]
                    )

                    PixelBuilding(index: index, accent: accent)
                        .frame(width: width, height: height)
                        .position(
                            x: CGFloat(index) / 11 * geometry.size.width
                                + CGFloat(
                                    [
                                        -24, -8, 10, -14, 20, -18, 12, 22, -20,
                                        16, 4, 26,
                                    ][index]
                                ),
                            y: geometry.size.height - height / 2
                        )
                }

                PixelParticles(accent: accent)
                    .opacity(0.55)
            }
        }
    }
}

private struct PixelBuilding: View {
    let index: Int
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            Triangle()
                .fill(
                    index.isMultiple(of: 2)
                        ? Color.pink.opacity(0.72) : Color.purple.opacity(0.58)
                )
                .frame(height: 42)

            Rectangle()
                .fill(
                    Color(red: 0.08, green: 0.14, blue: 0.34).opacity(
                        index.isMultiple(of: 2) ? 0.72 : 0.55
                    )
                )
                .overlay {
                    VStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(0..<2, id: \.self) { column in
                                    Rectangle()
                                        .fill(
                                            (row + column + index).isMultiple(
                                                of: 3
                                            )
                                                ? .white.opacity(0.38)
                                                : accent.opacity(0.15)
                                        )
                                        .frame(width: 16, height: 24)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 24)
                }
        }
    }
}

private struct PixelOceanDetails: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            PixelClouds()
            MountainSkyDetails(accent: accent)
                .opacity(0.65)
        }
    }
}

private struct PixelLavaSkyDetails: View {
    let accent: Color

    var body: some View {
        ZStack {
            PixelParticles(accent: accent)
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(accent.opacity(0.28))
                    .frame(width: CGFloat(86 + index * 16), height: 10)
                    .rotationEffect(.degrees(Double(index * 9 - 24)))
                    .offset(
                        x: CGFloat(index * 47 - 190),
                        y: CGFloat(index * 23 - 135)
                    )
            }
        }
    }
}

private struct PixelIceSkyDetails: View {
    let accent: Color

    var body: some View {
        ZStack {
            MountainSkyDetails(accent: accent)
            PixelParticles(accent: accent)
        }
    }
}

private struct PixelClouds: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<6, id: \.self) { index in
                HStack(spacing: -8) {
                    ForEach(0..<4, id: \.self) { block in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.32))
                            .frame(
                                width: CGFloat(38 + block * 14),
                                height: CGFloat(22 + block % 2 * 18)
                            )
                    }
                }
                .position(
                    x: CGFloat(index * 73 % Int(max(geometry.size.width, 1))),
                    y: CGFloat(72 + index * 48)
                )
            }
        }
    }
}

private struct PixelParticles: View {
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<34, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        [accent, .pink, .orange, .white][index % 4].opacity(
                            0.68
                        )
                    )
                    .frame(
                        width: CGFloat(5 + index % 4 * 4),
                        height: CGFloat(16 + index % 3 * 7)
                    )
                    .rotationEffect(.degrees(Double(index * 17)))
                    .position(
                        x: CGFloat(
                            index * 47 % Int(max(geometry.size.width, 1))
                        ),
                        y: CGFloat(
                            index * 67 % Int(max(geometry.size.height, 1))
                        )
                    )
            }
        }
    }
}

private struct PixelLavaGroundDetails: View {
    var body: some View {
        ZStack {
            PixelStoneGroundDetails()
            ForEach(0..<14, id: \.self) { index in
                Capsule()
                    .fill(.orange.opacity(0.72))
                    .frame(width: CGFloat(70 + index % 4 * 36), height: 8)
                    .offset(
                        x: CGFloat(index * 41 % 380 - 190),
                        y: CGFloat(index * 19 % 140 - 70)
                    )
            }
        }
    }
}

private struct PixelIceGroundDetails: View {
    var body: some View {
        ZStack {
            PixelStoneGroundDetails()
            ForEach(0..<16, id: \.self) { index in
                Rectangle()
                    .fill(.white.opacity(0.32))
                    .frame(width: CGFloat(26 + index % 4 * 16), height: 8)
                    .offset(
                        x: CGFloat(index * 31 % 380 - 190),
                        y: CGFloat(index * 23 % 140 - 70)
                    )
            }
        }
    }
}

private struct PixelSandGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<26, id: \.self) { index in
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(width: CGFloat(10 + index % 5 * 8), height: 5)
                    .offset(
                        x: CGFloat(index * 29 % 380 - 190),
                        y: CGFloat(index * 17 % 140 - 70)
                    )
            }
        }
    }
}

private struct PixelStoneGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.black.opacity(0.28), lineWidth: 2)
                    .frame(width: CGFloat(58 + index % 4 * 24), height: 22)
                    .offset(
                        x: CGFloat(index * 43 % 420 - 210),
                        y: CGFloat(index * 21 % 150 - 75)
                    )
            }
        }
    }
}

private struct MountainSkyDetails: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(0..<4, id: \.self) { index in
                MountainLayer()
                    .fill(accent.opacity(0.12 + Double(index) * 0.08))
                    .frame(height: CGFloat(180 + index * 56))
                    .offset(y: CGFloat(index * 28))
            }
        }
    }
}

private struct LavaSkyDetails: View {
    let accent: Color

    var body: some View {
        ZStack {
            ForEach(0..<9, id: \.self) { index in
                Capsule()
                    .fill(accent.opacity(0.25))
                    .frame(width: CGFloat(90 + index * 16), height: 18)
                    .rotationEffect(.degrees(Double(index * 7 - 18)))
                    .offset(
                        x: CGFloat(index * 43 - 180),
                        y: CGFloat(index * 21 - 110)
                    )
            }
        }
    }
}

private struct IceSkyDetails: View {
    let accent: Color

    var body: some View {
        ZStack {
            ForEach(0..<24, id: \.self) { index in
                Rectangle()
                    .stroke(accent.opacity(0.45), lineWidth: 1.2)
                    .frame(
                        width: CGFloat(8 + index % 5 * 5),
                        height: CGFloat(8 + index % 5 * 5)
                    )
                    .rotationEffect(.degrees(Double(index * 17)))
                    .offset(
                        x: CGFloat(index * 31 % 340 - 170),
                        y: CGFloat(index * 47 % 520 - 260)
                    )
            }
        }
    }
}

private struct CitySkyDetails: View {
    let accent: Color

    var body: some View {
        HStack(alignment: .bottom, spacing: -8) {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 6)
                    .fill(accent.opacity(0.18))
                    .frame(width: 74, height: CGFloat(120 + index % 3 * 38))
                    .overlay {
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                HStack(spacing: 8) {
                                    Rectangle().fill(.white.opacity(0.25))
                                        .frame(width: 12, height: 18)
                                    Rectangle().fill(.white.opacity(0.18))
                                        .frame(width: 12, height: 18)
                                }
                            }
                        }
                    }
            }
        }
    }
}

private struct LavaGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(.orange.opacity(0.5))
                    .frame(width: CGFloat(70 + index % 4 * 34), height: 8)
                    .offset(
                        x: CGFloat(index * 39 % 360 - 180),
                        y: CGFloat(index * 17 % 120 - 60)
                    )
            }
        }
    }
}

private struct IceGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<16, id: \.self) { index in
                Rectangle()
                    .stroke(.white.opacity(0.35), lineWidth: 1)
                    .frame(width: CGFloat(28 + index % 4 * 14), height: 18)
                    .rotationEffect(.degrees(Double(index * 11)))
                    .offset(
                        x: CGFloat(index * 29 % 360 - 180),
                        y: CGFloat(index * 19 % 120 - 60)
                    )
            }
        }
    }
}

private struct SandGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<18, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: CGFloat(5 + index % 4 * 3))
                    .offset(
                        x: CGFloat(index * 23 % 360 - 180),
                        y: CGFloat(index * 31 % 120 - 60)
                    )
            }
        }
    }
}

private struct StoneGroundDetails: View {
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.black.opacity(0.18), lineWidth: 2)
                    .frame(width: CGFloat(70 + index % 3 * 22), height: 28)
                    .offset(
                        x: CGFloat(index * 42 % 360 - 180),
                        y: CGFloat(index * 23 % 120 - 60)
                    )
            }
        }
    }
}

private struct MountainLayer: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(
                to: CGPoint(x: rect.width * 0.18, y: rect.height * 0.48)
            )
            path.addLine(to: CGPoint(x: rect.width * 0.34, y: rect.maxY))
            path.addLine(
                to: CGPoint(x: rect.width * 0.52, y: rect.height * 0.32)
            )
            path.addLine(to: CGPoint(x: rect.width * 0.72, y: rect.maxY))
            path.addLine(
                to: CGPoint(x: rect.width * 0.88, y: rect.height * 0.44)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

extension Color {
    init?(hex: String?) {
        guard let hex else {
            return nil
        }

        let cleaned = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
