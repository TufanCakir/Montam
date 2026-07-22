//
//  TradeView.swift
//  Monster Transorfmieren
//

import SwiftData
import SwiftUI

struct TradeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @State private var viewModel = TradeViewModel()

    private var save: GameSaveData? {
        saves.first
    }

    var body: some View {
        VStack(spacing: 0) {
            TradeTitleBar()

            if viewModel.offers.isEmpty {
                TradeEmptyState()
                    .padding(18)
            } else {
                tradeList
            }
        }
        .background(TradeBackground())
        .overlay(alignment: .center) {
            if let message = viewModel.message {
                TradeToast(message: message)
            }
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    private var tradeList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                TradeWalletPanel(save: save)

                ForEach(viewModel.sectionTitles, id: \.self) { section in
                    TradeSection(
                        title: section,
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
        let message = TradeInventoryService.performTrade(
            offer,
            saves: saves,
            modelContext: modelContext
        )
        viewModel.showMessage(message)
    }
}

#Preview {
    TradeView()
}
