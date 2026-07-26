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
                HStack(alignment: .top, spacing: 10) {
                    ShopSideCategories(
                        section: viewModel.selectedSection,
                        hasProducts: hasProductsInSelectedSection
                    )

                    shopContent
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 24)
            }

            ShopSectionTabs(selectedSection: $viewModel.selectedSection)
        }
        .background(ShopBackground())
        .overlay {
            if let message = viewModel.purchaseMessage {
                ShopToast(message: message)
            }
        }
        .task {
            await viewModel.loadIfNeeded(store: paymentStore)
        }
        .onChange(of: paymentStore.purchasedProductIds) { _, productIds in
            gameStore.syncShopEntitlements(productIds: productIds)
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
                products: viewModel.selectedItemProducts,
                onBuy: buyItem
            )
        }
    }

    private var hasProductsInSelectedSection: Bool {
        switch viewModel.selectedSection {
        case .item:
            !viewModel.selectedItemProducts.isEmpty
        case .pass, .premiumCurrency:
            !viewModel.selectedProducts.isEmpty
        }
    }

    private func buyItem(_ product: ItemShopProductData) {
        let didBuy = gameStore.purchaseItem(product)
        viewModel.purchaseMessage =
            didBuy ? "Item gekauft." : "Nicht genug Währung."
    }

    private func buy(_ product: ShopProductData) {
        if product.purchaseType == .softCurrency {
            let didBuy = gameStore.purchaseSoftCurrencyProduct(product)
            viewModel.purchaseMessage =
                didBuy ? "Item gekauft." : "Nicht genug Währung."
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
                viewModel.purchaseMessage = "Kauf abgeschlossen."
            case .pending:
                viewModel.purchaseMessage = "Kauf wartet auf Bestätigung."
            case .cancelled:
                viewModel.purchaseMessage = nil
            case .failed(let message):
                viewModel.purchaseMessage = message
            }
        }
    }

    private func restorePurchases() {
        Task {
            await paymentStore.restorePurchases()
            gameStore.syncShopEntitlements(
                productIds: paymentStore.purchasedProductIds
            )
            viewModel.purchaseMessage = "Käufe wurden wiederhergestellt."
        }
    }

    private func priceTitle(_ product: ShopProductData) -> String {
        viewModel.priceTitle(for: product, store: paymentStore)
    }
}

#Preview {
    RootView()
}
