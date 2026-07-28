//
//  AppFlowPersistenceView.swift
//  Montam
//
//  Created by Tufan Cakir on 23.07.26.
//

import SwiftData
import SwiftUI

struct AppFlowPersistenceView: View {
    @Binding var didAcknowledgePurchaseNotice: Bool
    @Binding var didTapStart: Bool
    @Binding var didFinishOnboarding: Bool
    let onResetToStart: () -> Void

    @Query private var saves: [GameSaveData]

    var body: some View {
        if !didAcknowledgePurchaseNotice {
            PurchaseNoticeView {
                didAcknowledgePurchaseNotice = true
            }
        } else if !didTapStart {
            StartView {
                didTapStart = true
            } onDataDeleted: {
                onResetToStart()
            }
        } else if didFinishOnboarding || hasCompletedOnboarding {
            RootView {
                onResetToStart()
            }
        } else {
            OnboardingView {
                didFinishOnboarding = true
            }
        }
    }

    private var hasCompletedOnboarding: Bool {
        saves.first?.didCompleteOnboarding == true
    }
}
