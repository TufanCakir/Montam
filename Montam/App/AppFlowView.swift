//
//  AppFlowView.swift
//  Montam
//
//  Created by Tufan Cakir on 21.07.26.
//

import SwiftUI

struct AppFlowView: View {

    @State private var remoteContent = RemoteContentService.shared
    @State private var didAcknowledgePurchaseNotice = false
    @State private var didTapStart = false
    @State private var didFinishOnboarding = false

    var body: some View {
        ZStack {
            AppFlowPersistenceView(
                didAcknowledgePurchaseNotice: $didAcknowledgePurchaseNotice,
                didTapStart: $didTapStart,
                didFinishOnboarding: $didFinishOnboarding,
                onResetToStart: resetToStart
            )

            if remoteContent.isUpdating,
                let statusText = remoteContent.statusText
            {
                RemoteContentLoadingOverlay(
                    text: statusText,
                    progress: remoteContent.progress,
                    detailText: remoteContent.progressText
                )
            }
        }
        .task {
            await remoteContent.updateAtLaunch(showOverlay: true)
        }
        .statusBarHidden(true)
    }

    private func resetToStart() {
        didAcknowledgePurchaseNotice = false
        didTapStart = false
        didFinishOnboarding = false
    }
}
