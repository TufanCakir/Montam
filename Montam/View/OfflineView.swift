//
//  OfflineView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct OfflineView: View {
    @ObservedObject private var network = NetworkMonitor.shared

    var body: some View {

        VStack(spacing: 22) {
            Spacer()

            statusMark

            VStack(spacing: 9) {
                Text("REMOTE LOST")
                    .font(
                        .system(size: 31, weight: .black, design: .rounded)
                    )
                    .foregroundStyle(.white)
                    .tracking(1.2)

                Text("MONTAM BRAUCHT EINE AKTIVE VERBINDUNG")
                    .font(
                        .system(size: 12, weight: .black, design: .rounded)
                    )
                    .foregroundStyle(MontamPalette.mutedText)
                    .multilineTextAlignment(.center)
            }

            connectionPanel

            retryButton

            Spacer()
        }
        .padding(24)
        .background {
            MontamBackground()
        }
    }

    private var statusMark: some View {
        ZStack {
            MontamEvolutionShape()
                .stroke(MontamPalette.gold, lineWidth: 3)
                .frame(width: 164, height: 116)

            MontamEvolutionShape()
                .stroke(MontamPalette.blue, lineWidth: 2)
                .frame(width: 132, height: 90)
                .mask(
                    MontamEvolutionShape()
                        .frame(width: 164, height: 116)
                )

            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 78, height: 78)
                .opacity(network.isChecking ? 0.45 : 1)

            if network.isChecking {
                ProgressView()
                    .tint(MontamPalette.gold)
                    .scaleEffect(1.2)
            }
        }
    }

    private var connectionPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("STATUS")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)

                Spacer()

                Text(network.isChecking ? "CHECKING" : "OFFLINE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(
                        network.isChecking ? MontamPalette.blue : .red
                    )
            }

            Rectangle()
                .fill(MontamPalette.gold.opacity(0.75))
                .frame(height: 2)

            Text(
                "Remote JSONs und Assets koennen gerade nicht synchronisiert werden."
            )
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)
            .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
        .overlay(
            MontamCutRectangle(cut: 18)
                .stroke(MontamPalette.blue, lineWidth: 1.6)
        )
    }

    private var retryButton: some View {
        Button {
            network.checkConnection()
        } label: {
            HStack(spacing: 10) {
                if network.isChecking {
                    ProgressView()
                        .tint(MontamPalette.black)
                }

                Text(network.isChecking ? "PRUEFE REMOTE" : "ERNEUT PRUEFEN")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(MontamPalette.gold)
            .clipShape(MontamEvolutionShape())
            .overlay(
                MontamEvolutionShape()
                    .stroke(MontamPalette.blue, lineWidth: 1.6)
            )
        }
        .buttonStyle(.plain)
        .disabled(network.isChecking)
        .opacity(network.isChecking ? 0.72 : 1)
    }
}

#Preview {
    OfflineView()
}
