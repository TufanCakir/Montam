//
//  BattleStageOverlay.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftUI

struct BattleStageState: Equatable {
    let stageNumber: Int
    let currentWaveIndex: Int
    let totalWaves: Int
    let isBossWave: Bool

    static let empty = BattleStageState(
        stageNumber: 1,
        currentWaveIndex: 0,
        totalWaves: 1,
        isBossWave: false
    )
}

struct BattleStageOverlay: View {
    let state: BattleStageState

    var body: some View {
        VStack(spacing: 10) {
            waveDots

            ZStack {
                StageWaveBannerShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                .blue,
                                .black,
                                .blue
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: accentColor.opacity(0.36), radius: 12, y: 4)

                StageWaveBannerShape()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.18),
                                accentColor.opacity(0.95),
                                .white.opacity(0.22)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text(AppLocalizationService.text("battle.stage", state.stageNumber))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: 292, height: 58)
        }
        .allowsHitTesting(false)
    }

    private var waveDots: some View {
        HStack(spacing: 10) {
            ForEach(0..<max(state.totalWaves, 1), id: \.self) { index in
                Capsule()
                    .fill(
                        index <= state.currentWaveIndex
                            ? accentColor
                            : Color.white.opacity(0.32)
                    )
                    .frame(
                        width: index == state.currentWaveIndex ? 18 : 9,
                        height: 7
                    )
                    .overlay(
                        Capsule().stroke(
                            index == state.currentWaveIndex
                                ? .white.opacity(0.9)
                                : .clear,
                            lineWidth: 1
                        )
                    )
            }
        }
    }

    private var waveTitle: String {
        state.isBossWave
            ? AppLocalizationService.text("battle.boss")
            : AppLocalizationService.text("battle.wave")
    }

    private var accentColor: Color {
        state.isBossWave ? .red : .cyan
    }
}

private struct StageWaveBannerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = rect.midY
        let leftInset = width * 0.06
        let rightInset = width * 0.94

        path.move(to: CGPoint(x: leftInset, y: midY))
        path.addCurve(
            to: CGPoint(x: width * 0.18, y: height * 0.13),
            control1: CGPoint(x: width * 0.07, y: height * 0.22),
            control2: CGPoint(x: width * 0.11, y: height * 0.1)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.04),
            control1: CGPoint(x: width * 0.28, y: height * 0.2),
            control2: CGPoint(x: width * 0.36, y: height * -0.02)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.82, y: height * 0.13),
            control1: CGPoint(x: width * 0.64, y: height * 0.1),
            control2: CGPoint(x: width * 0.72, y: height * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: rightInset, y: midY),
            control1: CGPoint(x: width * 0.89, y: height * 0.1),
            control2: CGPoint(x: width * 0.93, y: height * 0.22)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.82, y: height * 0.87),
            control1: CGPoint(x: width * 0.93, y: height * 0.78),
            control2: CGPoint(x: width * 0.89, y: height * 0.9)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.96),
            control1: CGPoint(x: width * 0.72, y: height * 0.8),
            control2: CGPoint(x: width * 0.64, y: height * 1.02)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.18, y: height * 0.87),
            control1: CGPoint(x: width * 0.36, y: height * 0.9),
            control2: CGPoint(x: width * 0.28, y: height * 0.8)
        )
        path.addCurve(
            to: CGPoint(x: leftInset, y: midY),
            control1: CGPoint(x: width * 0.11, y: height * 0.9),
            control2: CGPoint(x: width * 0.07, y: height * 0.78)
        )
        path.closeSubpath()

        return path
    }
}

#Preview {
    BattleStageOverlay(
        state: BattleStageState(
            stageNumber: 12,
            currentWaveIndex: 1,
            totalWaves: 3,
            isBossWave: false
        )
    )
}
