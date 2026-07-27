//
//  StoreKitShopManager.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Combine
import Foundation
import StoreKit

@MainActor
final class StoreKitShopManager: ObservableObject {
    @Published private(set) var requestedProductIds: Set<String> = []
    @Published private(set) var productsById: [String: Product] = [:]
    @Published private(set) var purchasedProductIds: Set<String> = []
    @Published private(set) var unavailableProductIds: Set<String> = []
    @Published private(set) var isLoadingProducts = false
    @Published var errorMessage: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = listenForTransactions()
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProducts(productIds: [String], force: Bool = false) async {
        let uniqueIds = normalizedProductIds(productIds)

        if !force, requestedProductIds == Set(uniqueIds),
            !productsById.isEmpty || !unavailableProductIds.isEmpty
        {
            await refreshEntitlements()
            return
        }

        requestedProductIds = Set(uniqueIds)
        errorMessage = nil

        guard !uniqueIds.isEmpty else {
            productsById = [:]
            unavailableProductIds = []
            isLoadingProducts = false
            return
        }

        do {
            isLoadingProducts = true
            defer { isLoadingProducts = false }

            let products = try await Product.products(for: uniqueIds)
            productsById = Dictionary(
                uniqueKeysWithValues: products.map { ($0.id, $0) }
            )
            unavailableProductIds = Set(uniqueIds).subtracting(
                productsById.keys
            )
            errorMessage =
                unavailableProductIds.isEmpty
                ? nil : "Einige Store-Produkte sind nicht verfügbar."

            await refreshEntitlements()
        } catch {
            productsById = [:]
            errorMessage = "Store konnte nicht geladen werden."
            unavailableProductIds = Set(uniqueIds)
        }
    }

    func purchase(_ productData: ShopProductData) async -> StorePurchaseResult {
        let productId = productData.productId.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard let product = productsById[productId] else {
            return .failed("StoreKit findet \(productId) nicht.")
        }

        do {
            let wasPurchased = purchasedProductIds.contains(productId)

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verifiedTransaction(from: verification)
                await transaction.finish()

                if productData.purchaseType == .nonConsumable {
                    purchasedProductIds.insert(productId)
                }

                let shouldApplyRewards =
                    productData.purchaseType == .consumable || !wasPurchased
                return .purchased(
                    productData,
                    shouldApplyRewards: shouldApplyRewards
                )

            case .pending:
                return .pending

            case .userCancelled:
                return .cancelled

            @unknown default:
                return .failed("Unbekannter StoreKit-Status.")
            }
        } catch {
            return .failed("Kauf konnte nicht abgeschlossen werden.")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = "Käufe konnten nicht wiederhergestellt werden."
        }
    }

    func localizedPrice(for productData: ShopProductData) -> String {
        productsById[normalizedProductId(productData.productId)]?.displayPrice
            ?? "..."
    }

    func isStoreKitUnavailable(_ productData: ShopProductData) -> Bool {
        let productId = normalizedProductId(productData.productId)

        return productData.purchaseType != .softCurrency
            && requestedProductIds.contains(productId)
            && unavailableProductIds.contains(productId)
    }

    func isPurchased(_ productData: ShopProductData) -> Bool {
        return productData.purchaseType == .nonConsumable
            && purchasedProductIds.contains(
                normalizedProductId(productData.productId)
            )
    }

    private func refreshEntitlements() async {
        var purchasedIds: Set<String> = []

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                transaction.revocationDate == nil
            else {
                continue
            }

            purchasedIds.insert(transaction.productID)
        }

        purchasedProductIds = purchasedIds
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try self.verifiedTransaction(from: result)
                    if transaction.revocationDate == nil {
                        self.purchasedProductIds.insert(transaction.productID)
                    } else {
                        self.purchasedProductIds.remove(transaction.productID)
                    }
                    await transaction.finish()
                } catch {
                    self.errorMessage = "Kauf konnte nicht verifiziert werden."
                }
            }
        }
    }

    private func normalizedProductIds(_ productIds: [String]) -> [String] {
        Array(Set(productIds.map(normalizedProductId).filter { !$0.isEmpty }))
            .sorted()
    }

    private func normalizedProductId(_ productId: String) -> String {
        productId.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func verifiedTransaction(
        from result: VerificationResult<Transaction>
    ) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw StorePurchaseError.unverified
        }
    }
}

enum StorePurchaseResult {
    case purchased(ShopProductData, shouldApplyRewards: Bool)
    case pending
    case cancelled
    case failed(String)
}

private enum StorePurchaseError: Error {
    case unverified
}
