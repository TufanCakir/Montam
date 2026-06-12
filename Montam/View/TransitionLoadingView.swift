//
//  TransitionLoadingView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct TransitionLoadingView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var bladeOffset: CGFloat = -180
    @State private var pulse = false
    @State private var dots = 0

    var body: some View {
        VStack(spacing: 26) {
            Spacer()

            ZStack {
                MontamEvolutionShape()
                    .stroke(MontamPalette.gold, lineWidth: 3)
                    .frame(width: 156, height: 112)

                MontamEvolutionShape()
                    .stroke(MontamPalette.blue, lineWidth: 2)
                    .frame(width: 126, height: 88)
                    .offset(x: bladeOffset)
                    .mask(
                        MontamEvolutionShape()
                            .frame(width: 156, height: 112)
                    )

                RemoteAssetImage(name: appModel.currentLoadingImage)
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .scaleEffect(pulse ? 1.05 : 0.96)
            }

            VStack(spacing: 8) {
                Text(appModel.loadingTitle)
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.2)

                Text("\(appModel.loadingSubtitle)\(loadingDots)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MontamScreenBackground())
        .onAppear {
            pulse = true
            bladeOffset = 180
            startDotsAnimation()
        }
        .animation(
            .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
            value: pulse
        )
        .animation(
            .linear(duration: 1.15).repeatForever(autoreverses: false),
            value: bladeOffset
        )
        .transition(.opacity)
    }

    private var loadingDots: String {
        String(repeating: ".", count: dots)
    }

    private func startDotsAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
            dots = (dots + 1) % 4
        }
    }
}

#Preview {
    TransitionLoadingView()
        .environmentObject(AppModel())
}
