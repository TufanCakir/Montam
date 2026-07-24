//
//  AppFlowView.swift
//  Montam
//
//  Created by Tufan Cakir on 21.07.26.
//

import SwiftUI

struct AppFlowView: View {

    @State private var remoteContent = RemoteContentService.shared
    @State private var didTapStart = false
    @State private var didFinishOnboarding = false

    var body: some View {
        ZStack {
            AppFlowPersistenceView(
                didTapStart: $didTapStart,
                didFinishOnboarding: $didFinishOnboarding,
                onResetToStart: resetToStart
            )

            if remoteContent.isUpdating,
                let statusText = remoteContent.statusText
            {
                RemoteContentLoadingOverlay(text: statusText)
            }
        }
        .task {
            await remoteContent.updateAtLaunch()
        }
        .statusBarHidden(true)
    }

    private func resetToStart() {
        didTapStart = false
        didFinishOnboarding = false
    }
}
