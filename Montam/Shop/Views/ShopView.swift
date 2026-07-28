//
//  ShopView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct ShopView: View {
    let gameStore: GameStore

    @StateObject private var paymentStore = StoreKitShopManager()
    @State private var viewModel = ShopViewModel()
    @AppStorage(AppLocalizationService.languageKey)
    private var languageRawValue = AppLanguage.german.rawValue

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                shopContent
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }

            ShopSectionTabs(selectedSection: $viewModel.selectedSection)
        }
        .overlay {
            if let message = viewModel.purchaseMessage {
                ShopToast(message: message)
            }
        }
        .task {
            await viewModel.loadIfNeeded(store: paymentStore)
        }
        .padding(.top, 50)
    }

    @ViewBuilder
    private var shopContent: some View {
        switch viewModel.selectedSection {
        case .pass:
            ShopPassContent(
                products: viewModel.selectedProducts,
                cardState: productCardState,
                onBuy: buyProduct,
                onRestore: restorePurchases
            )
        case .premiumCurrency:
            ShopProductGridContent(
                products: viewModel.selectedProducts,
                emptyTitle: viewModel.selectedEmptyTitle,
                cardState: productCardState,
                onBuy: buyProduct
            )
        case .item:
            ItemShopContent(
                products: viewModel.itemProducts,
                emptyTitle: viewModel.selectedEmptyTitle,
                cardState: itemCardState,
                onBuy: buyItemProduct
            )
        }
    }

    private func buyItemProduct(_ product: ItemShopProductData) {
        viewModel.buyItem(product, gameStore: gameStore)
    }

    private func buyProduct(_ product: ShopProductData) {
        Task {
            await viewModel.buy(
                product,
                gameStore: gameStore,
                store: paymentStore
            )
        }
    }

    private func restorePurchases() {
        Task {
            await viewModel.restorePurchases(
                gameStore: gameStore,
                store: paymentStore
            )
        }
    }

    private func productCardState(
        _ product: ShopProductData
    ) -> ShopStoreProductCardState {
        viewModel.cardState(
            for: product,
            gameStore: gameStore,
            store: paymentStore
        )
    }

    private func itemCardState(
        _ product: ItemShopProductData
    ) -> ShopItemProductCardState {
        viewModel.itemCardState(for: product)
    }
}
