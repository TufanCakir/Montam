//
//  RemoteLoadingView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct RemoteLoadingView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var remote = RemoteDownloadManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 118, height: 118)

            VStack(spacing: 7) {
                Text("REMOTE LOAD")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(remote.statusText.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(MontamPalette.black)

                        Rectangle()
                            .fill(MontamPalette.gold)
                            .frame(width: proxy.size.width * remote.progress)
                    }
                }
                .frame(height: 16)
                .overlay(
                    MontamCutRectangle(cut: 5)
                        .stroke(MontamPalette.blue, lineWidth: 1.5)
                )
                .clipShape(MontamCutRectangle(cut: 5))

                HStack {
                    Text("\(Int(remote.progress * 100))%")
                    Spacer()
                    Text("\(remote.completedItems) / \(remote.totalItems)")
                    Spacer()
                    Text(remote.formattedBytes(remote.downloadedBytes))
                }
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
            }
            .padding(16)
            .background(MontamPalette.panel)
            .clipShape(MontamCutRectangle(cut: 18))

            VStack(spacing: 11) {
                actionButton(
                    title: "ALLES HERUNTERLADEN",
                    tint: MontamPalette.gold
                ) {
                    remote.downloadAll {
                        continueAfterServiceCheck()
                    }
                }

                actionButton(
                    title: "REMOTE STARTEN",
                    tint: MontamPalette.blue
                ) {
                    remote.preload {
                        continueAfterServiceCheck()
                    }
                }
            }
            .disabled(remote.isLoading)
            .opacity(remote.isLoading ? 0.55 : 1)

            Spacer()
        }
        .padding(22)
        .background(MontamScreenBackground())
        .onAppear {
            remote.refreshManifest()
            continueIfCached()
        }
    }

    private func continueIfCached() {
        guard remote.hasCompleteCache else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            continueAfterServiceCheck()
        }
    }

    private func continueAfterServiceCheck() {
        ServiceStatusManager.shared.refresh()
        appModel.appState =
            ServiceStatusManager.shared.activeMaintenance == nil
            ? .start
            : .maintenance
    }

    private func actionButton(
        title: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(
                    tint == MontamPalette.gold
                        ? MontamPalette.black : .white
                )
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(tint)
                .clipShape(MontamEggShape())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RemoteLoadingView()
        .environmentObject(AppModel())
}
