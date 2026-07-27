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

    var body: some View {
        VStack(spacing: 0) {

            ShopWalletFilterBar(
                wallet: gameStore.shopWallet,
                selectedSection: $viewModel.selectedSection
            )

            ScrollView(.vertical, showsIndicators: false) {
                shopContent
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
                    .padding(.top, 22)
                    .padding(.bottom, 24)
            }

            ShopSectionTabs(selectedSection: $viewModel.selectedSection)
        }
        .background(AppScreenBackground())
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
                store: paymentStore,
                onBuy: buy,
                isPurchased: isPurchased,
                priceTitle: priceTitle,
                onRestore: restorePurchases
            )
        case .premiumCurrency:
            ShopProductGridContent(
                products: viewModel.selectedProducts,
                emptyTitle: "Keine Premium-Produkte",
                store: paymentStore,
                priceTitle: priceTitle,
                onBuy: buy
            )
        case .item:
            ItemShopContent(
                products: viewModel.itemProducts,
                onBuy: buyItem
            )
        }
    }

    private func buyItem(_ product: ItemShopProductData) {
        let didBuy = gameStore.purchaseItem(product)
        showPurchaseMessage(didBuy ? "Item gekauft." : "Nicht genug Währung.")
    }

    private func buy(_ product: ShopProductData) {
        if product.purchaseType == .softCurrency {
            let didBuy = gameStore.purchaseSoftCurrencyProduct(product)
            showPurchaseMessage(
                didBuy ? "Item gekauft." : "Nicht genug Währung."
            )
            return
        }

        Task {
            let result = await paymentStore.purchase(product)

            switch result {
            case .purchased(let product, let shouldApplyRewards):
                if shouldApplyRewards {
                    gameStore.applyShopRewards(from: product)
                } else {
                    gameStore.syncShopEntitlements(
                        productIds: paymentStore.purchasedProductIds
                    )
                }
                showPurchaseMessage("Kauf abgeschlossen.")
            case .pending:
                showPurchaseMessage("Kauf wartet auf Bestätigung.")
            case .cancelled:
                viewModel.purchaseMessage = nil
            case .failed(let message):
                handlePurchaseFailure(message)
            }
        }
    }

    private func restorePurchases() {
        Task {
            await paymentStore.restorePurchases()
            gameStore.syncShopEntitlements(
                productIds: paymentStore.purchasedProductIds
            )
            showPurchaseMessage("Käufe wurden wiederhergestellt.")
        }
    }

    private func handlePurchaseFailure(_ message: String) {
        guard !message.contains("StoreKit findet") else {
            viewModel.purchaseMessage = nil
            return
        }

        showPurchaseMessage(message)
    }

    private func showPurchaseMessage(_ message: String) {
        viewModel.purchaseMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            if viewModel.purchaseMessage == message {
                viewModel.purchaseMessage = nil
            }
        }
    }

    private func priceTitle(_ product: ShopProductData) -> String {
        viewModel.priceTitle(for: product, store: paymentStore)
    }

    private func isPurchased(_ product: ShopProductData) -> Bool {
        if product.purchaseType == .nonConsumable,
            product.rewards.unlockEventPass == true
        {
            return gameStore.hasEventPass
        }

        return paymentStore.isPurchased(product)
    }
}

#Preview {
    RootView()
}
