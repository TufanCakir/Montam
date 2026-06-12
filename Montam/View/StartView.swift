//
//  StartView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct StartView: View {
    @EnvironmentObject private var appModel: AppModel

    private let black = MontamPalette.black
    private let panel = MontamPalette.panel
    private let gold = MontamPalette.gold
    private let blue = MontamPalette.blue

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 42)

            logoSection

            Spacer(minLength: 44)

            actionStack
                .padding(.bottom, 34)
        }
        .padding(.horizontal, 22)
        .background {
            MontamBackground()
        }
    }

    private var logoSection: some View {
        ZStack {
            MontamEvolutionShape()
                .fill(
                    LinearGradient(
                        colors: [
                            panel,
                            blue.opacity(0.20),
                            black.opacity(0.92),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 258, height: 258)
                .overlay(
                    MontamEvolutionShape()
                        .stroke(.white.opacity(0.10), lineWidth: 1)
                )

            MontamEvolutionShape()
                .stroke(gold, lineWidth: 2)
                .frame(width: 230, height: 230)

            MontamEvolutionShape()
                .stroke(blue, lineWidth: 3)
                .frame(width: 198, height: 198)

            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 176, height: 176)
        }
    }

    private var actionStack: some View {
        VStack(spacing: 13) {
            actionButton(
                title: "Spiel starten",
                image: "skin_cryon_feral_default",
                style: .primary
            ) {
                appModel.navigateWithLoading {
                    appModel.startGame()
                }
            }
            actionButton(
                title: "Summon",
                image: "skin_crygon_tamed_default",
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
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isPrimary
                                ? [gold, gold.opacity(0.78)]
                                : [
                                    panel, blue.opacity(0.42),
                                    black.opacity(0.88),
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(isPrimary ? blue : gold, lineWidth: 1.6)
                    )

                HStack(spacing: 13) {
                    RemoteAssetImage(name: image)
                        .scaledToFit()
                        .padding(7)
                        .frame(width: 40, height: 40)
                        .background(
                            MontamEvolutionShape()
                                .fill(isPrimary ? blue.opacity(0.92) : gold)
                        )
                        .overlay(
                            MontamEvolutionShape()
                                .stroke(.white.opacity(0.20), lineWidth: 1)
                        )

                    Text(title)
                        .font(
                            .system(.headline, design: .rounded, weight: .black)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(isPrimary ? black : gold)
                        .padding(.trailing, isPrimary ? 12 : 9)
                }
                .padding(.leading, 16)
                .padding(.trailing, 28)
            }
            .foregroundStyle(isPrimary ? black : .white)
            .frame(maxWidth: .infinity)
            .frame(height: isPrimary ? 62 : 56)
            .offset(x: isPrimary ? 0 : 10)
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
