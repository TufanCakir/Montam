//
//  MaintenanceView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct MaintenanceView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var service = ServiceStatusManager.shared

    var body: some View {
        ZStack {
            MontamScreenBackground()

            VStack(spacing: 22) {
                Spacer()

                RemoteAssetImage(name: maintenance?.icon ?? "montam_icon")
                    .scaledToFit()
                    .frame(width: 112, height: 112)

                VStack(spacing: 8) {
                    Text(
                        (maintenance?.title ?? "WARTUNGSARBEITEN").uppercased()
                    )
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                    Text(
                        maintenance?.message
                            ?? "Montam wird gerade aktualisiert."
                    )
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .multilineTextAlignment(.center)
                }

                if let endDate = maintenance?.endDate {
                    infoPanel(title: "ENDET", value: endDate)
                }

                Button {
                    service.refresh()
                    appModel.appState =
                        service.activeMaintenance == nil ? .start : .maintenance
                } label: {
                    Text("ERNEUT PRUEFEN")
                        .font(
                            .system(size: 15, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(MontamPalette.gold)
                        .clipShape(MontamEggShape())
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            service.refresh()
        }
    }

    private var maintenance: MaintenanceWindow? {
        service.activeMaintenance
    }

    private func infoPanel(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 16))
        .overlay(
            MontamCutRectangle(cut: 16)
                .stroke(MontamPalette.blue, lineWidth: 1.5)
        )
    }
}

#Preview {
    MaintenanceView()
        .environmentObject(AppModel())
}
