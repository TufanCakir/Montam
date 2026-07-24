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
        VStack(spacing: 4) {
            waveDots

            Text("Stage \(state.stageNumber)")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(state.isBossWave ? "Boss" : "Welle")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.blue)
                .lineLimit(1)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 8)
        .frame(minWidth: 190)
        .background(.black.opacity(0.38))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18).stroke(
                .cyan.opacity(0.85),
                lineWidth: 2
            )
        )
        .allowsHitTesting(false)
        .offset(y: 50)
    }

    private var waveDots: some View {
        HStack(spacing: 12) {
            ForEach(0..<max(state.totalWaves, 1), id: \.self) { index in
                Circle()
                    .fill(
                        index <= state.currentWaveIndex
                            ? Color.yellow
                            : Color.white.opacity(0.32)
                    )
                    .frame(
                        width: index == state.currentWaveIndex ? 12 : 9,
                        height: index == state.currentWaveIndex ? 12 : 9
                    )
                    .overlay(
                        Circle().stroke(
                            index == state.currentWaveIndex
                                ? .white.opacity(0.9)
                                : .clear,
                            lineWidth: 1
                        )
                    )
            }
        }
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
