//
//  TradeView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct TradeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @State private var viewModel = TradeViewModel()
    @State private var pendingOffer: TradeOfferData?

    private var save: GameSaveData? {
        saves.first
    }

    var body: some View {
        VStack(spacing: 0) {

            if viewModel.offers.isEmpty {
                TradeEmptyState()
                    .padding(18)
            } else {
                tradeList
            }
        }
        .overlay(alignment: .center) {
            ZStack {
                if let pendingOffer {
                    Color.black.opacity(0.62)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.pendingOffer = nil
                        }

                    GameConfirmationPopup(
                        title: AppLocalizationService.text(
                            "trade.confirmTitle"
                        ),
                        message: confirmationMessage(for: pendingOffer),
                        confirmTitle: AppLocalizationService.text(
                            "trade.confirmAction"
                        ),
                        cancelTitle: AppLocalizationService.text(
                            "settings.cancel"
                        ),
                        icon: "arrow.left.arrow.right.circle.fill",
                        onConfirm: {
                            performConfirmedTrade(pendingOffer)
                        },
                        onCancel: {
                            self.pendingOffer = nil
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                if let message = viewModel.message {
                    TradeToast(message: message)
                }
            }
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
        .padding(.top, 30)
    }

    private var tradeList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                TradeWalletPanel(save: save)

                ForEach(viewModel.sectionTitles, id: \.self) { section in
                    TradeSection(
                        title: viewModel.sectionTitle(for: section),
                        offers: viewModel.offers(in: section),
                        canTrade: canTrade,
                        onTrade: performTrade
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .padding(.bottom, 24)
        }
    }

    private func canTrade(_ offer: TradeOfferData) -> Bool {
        TradeInventoryService.canTrade(offer, save: save)
    }

    private func performTrade(_ offer: TradeOfferData) {
        guard canTrade(offer) else {
            viewModel.showMessage(
                AppLocalizationService.text(
                    "trade.notEnoughCurrency",
                    GameCurrency.title(for: offer.costCurrency)
                )
            )
            return
        }

        pendingOffer = offer
    }

    private func performConfirmedTrade(_ offer: TradeOfferData) {
        let message = TradeInventoryService.performTrade(
            offer,
            saves: saves,
            modelContext: modelContext
        )
        pendingOffer = nil
        viewModel.showMessage(message)
    }

    private func confirmationMessage(for offer: TradeOfferData) -> String {
        AppLocalizationService.text(
            "trade.confirmMessage",
            offer.costAmount,
            GameCurrency.title(for: offer.costCurrency),
            offer.rewardAmount,
            GameCurrency.title(for: offer.rewardCurrency)
        )
    }
}

#Preview {
    TradeView()
}
