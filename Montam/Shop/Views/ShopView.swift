//
//  ShopView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct ShopView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @StateObject private var store = StoreKitShopManager()
    @State private var viewModel = ShopViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ShopTitleBar(title: viewModel.selectedSection.title)
            ShopWalletFilterBar(selectedSection: $viewModel.selectedSection)

            ScrollView(.vertical, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ShopSideCategories(
                        section: viewModel.selectedSection,
                        hasProducts: !viewModel.selectedProducts.isEmpty
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
            await viewModel.loadIfNeeded(store: store)
        }
        .onChange(of: store.purchasedProductIds) { _, productIds in
            ShopInventoryService.syncEntitlements(
                productIds: productIds,
                saves: saves,
                modelContext: modelContext
            )
        }
    }

    @ViewBuilder
    private var shopContent: some View {
        switch viewModel.selectedSection {
        case .pass:
            ShopPassContent(
                products: viewModel.selectedProducts,
                store: store,
                onBuy: buy,
                onRestore: restorePurchases
            )
        case .premiumCurrency:
            ShopProductGridContent(
                products: viewModel.selectedProducts,
                emptyTitle: "Keine Premium-Produkte",
                store: store,
                onBuy: buy
            )
        case .item:
            ShopProductGridContent(
                products: viewModel.selectedProducts,
                emptyTitle: "Keine Item-Produkte",
                store: store,
                onBuy: buy
            )
        case .normal:
            ShopProductGridContent(
                products: viewModel.selectedProducts,
                emptyTitle: "Keine Normal-Shop-Produkte",
                store: store,
                onBuy: buy
            )
        }
    }

    private func buy(_ product: ShopProductData) {
        Task {
            let result = await store.purchase(product)

            switch result {
            case .purchased(let product):
                ShopInventoryService.applyRewards(
                    from: product,
                    saves: saves,
                    modelContext: modelContext
                )
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
            await store.restorePurchases()
            ShopInventoryService.syncEntitlements(
                productIds: store.purchasedProductIds,
                saves: saves,
                modelContext: modelContext
            )
            viewModel.purchaseMessage = "Käufe wurden wiederhergestellt."
        }
    }
}

#Preview {
    ShopView()
}
