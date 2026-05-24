//
//  StartView.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject private var appModel: AppModel

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)

    var body: some View {
        ZStack {
            black
                .ignoresSafeArea()

            backgroundGeometry

            VStack(spacing: 0) {
                Spacer(minLength: 52)

                logoSection

                Spacer(minLength: 56)

                actionStack
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 22)
        }
    }

    private var backgroundGeometry: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: width * 0.64, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height * 0.30))
                    path.addLine(to: CGPoint(x: width * 0.80, y: height * 0.23))
                    path.closeSubpath()
                }
                .fill(gold.opacity(0.10))

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.20))
                    path.addLine(to: CGPoint(x: width * 0.28, y: height * 0.12))
                    path.addLine(to: CGPoint(x: width * 0.12, y: height * 0.42))
                    path.addLine(to: CGPoint(x: 0, y: height * 0.48))
                    path.closeSubpath()
                }
                .fill(blue.opacity(0.15))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.50, y: height))
                    path.addLine(to: CGPoint(x: width, y: height * 0.82))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(gold.opacity(0.08))

                VStack(spacing: 0) {
                    accentLine(color: gold.opacity(0.64), leadingWidth: 82)
                        .frame(height: 2)
                        .padding(.top, 84)

                    Spacer()

                    accentLine(color: blue.opacity(0.70), leadingWidth: 44)
                        .frame(height: 2)
                        .padding(.bottom, 132)
                }
                .padding(.horizontal, 20)
            }
        }
        .ignoresSafeArea()
    }

    private var logoSection: some View {
        ZStack {
            AngledStartRectangle(cut: 34)
                .fill(panel)
                .frame(width: 258, height: 258)
                .overlay(
                    AngledStartRectangle(cut: 34)
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                )

            AngledStartRectangle(cut: 26)
                .stroke(gold, lineWidth: 2)
                .frame(width: 230, height: 230)

            AngledStartRectangle(cut: 18)
                .stroke(blue, lineWidth: 3)
                .frame(width: 198, height: 198)

            RemoteAssetImage(name: "drakon_icon")
                .scaledToFit()
                .frame(width: 176, height: 176)
        }
    }

    private var actionStack: some View {
        VStack(spacing: 13) {
            actionButton(
                title: "Spiel starten",
                image: "skin_pyro_baby_default",
                style: .primary
            ) {
                appModel.navigateWithLoading {
                    appModel.startGame()
                }
            }

            actionButton(
                title: "Summon",
                image: "skin_blazion_rookie_default",
                style: .secondary
            ) {
                appModel.navigateWithLoading {
                    if appModel.hasChosenStarter {
                        appModel.selectedTab = .summon
                        appModel.appState = .home
                    } else {
                        appModel.appState = .starterSelection
                    }
                }
            }
        }
        .padding(.trailing, 6)
    }

    private func actionButton(
        title: String,
        image: String,
        style: StartActionStyle,
        action: @escaping () -> Void
    ) -> some View {
        let isPrimary = style == .primary

        return Button(action: action) {
            ZStack(alignment: .leading) {
                BladeStartButtonShape(
                    pointDepth: isPrimary ? 34 : 28,
                    slant: isPrimary ? 16 : 12
                )
                .fill(isPrimary ? gold : blue)

                BladeStartButtonShape(
                    pointDepth: isPrimary ? 34 : 28,
                    slant: isPrimary ? 16 : 12
                )
                .stroke(isPrimary ? blue : gold, lineWidth: isPrimary ? 0 : 1.5)

                HStack(spacing: 13) {
                    ZStack {
                        BladeStartIconPlate(pointDepth: 8)
                            .fill(isPrimary ? blue : gold)
                            .frame(width: 38, height: 34)

                        RemoteAssetImage(name: image)
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }

                    Text(title)
                        .font(
                            .system(.headline, design: .rounded, weight: .black)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Spacer()

                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 18, y: 15))
                        path.addLine(to: CGPoint(x: 0, y: 30))
                    }
                    .stroke(
                        isPrimary ? black : gold,
                        style: StrokeStyle(
                            lineWidth: 3,
                            lineCap: .square,
                            lineJoin: .miter
                        )
                    )
                    .frame(width: 18, height: 30)
                    .padding(.trailing, isPrimary ? 12 : 9)
                }
                .padding(.leading, 16)
                .padding(.trailing, 28)
            }
            .foregroundStyle(isPrimary ? black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: isPrimary ? 62 : 56)
            .offset(x: isPrimary ? 0 : 14)
        }
        .buttonStyle(.plain)
    }

    private func accentLine(color: Color, leadingWidth: CGFloat) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: leadingWidth)

            Rectangle()
                .fill(color.opacity(0.42))
                .frame(maxWidth: .infinity)
        }
    }
}

private enum StartActionStyle {
    case primary
    case secondary
}

private struct BladeStartButtonShape: Shape {
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

private struct BladeStartIconPlate: Shape {
    let pointDepth: CGFloat

    func path(in rect: CGRect) -> Path {
        let pointDepth = min(pointDepth, rect.width * 0.35)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct AngledStartRectangle: Shape {
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
    StartView()
        .environmentObject(AppModel())
}
