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
    @Published private(set) var productsById: [String: Product] = [:]
    @Published private(set) var purchasedProductIds: Set<String> = []
    @Published private(set) var unavailableProductIds: Set<String> = []
    @Published var errorMessage: String?

    func loadProducts(productIds: [String]) async {
        let uniqueIds = Array(Set(productIds)).sorted()

        do {
            let products = try await Product.products(for: uniqueIds)
            productsById = Dictionary(
                uniqueKeysWithValues: products.map { ($0.id, $0) }
            )
            unavailableProductIds = Set(uniqueIds).subtracting(
                productsById.keys
            )

            #if DEBUG
                let loadedIds = productsById.keys.sorted()
                if !loadedIds.isEmpty {
                    print(
                        "StoreKit loaded product IDs: \(loadedIds.joined(separator: ", "))"
                    )
                }

                if !unavailableProductIds.isEmpty {
                    print(
                        "StoreKit missing product IDs: \(unavailableProductIds.sorted().joined(separator: ", "))"
                    )
                }
            #endif

            await refreshEntitlements()
        } catch {
            errorMessage = "Store konnte nicht geladen werden."
            unavailableProductIds = Set(uniqueIds)

            #if DEBUG
                print(
                    "StoreKit product loading failed for IDs: \(uniqueIds.joined(separator: ", "))"
                )
            #endif
        }
    }

    func purchase(_ productData: ShopProductData) async -> StorePurchaseResult {
        guard let product = productsById[productData.productId] else {
            return .failed("StoreKit findet \(productData.productId) nicht.")
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verifiedTransaction(from: verification)
                await transaction.finish()

                if productData.purchaseType == .nonConsumable {
                    purchasedProductIds.insert(productData.productId)
                }

                return .purchased(productData)

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
        productsById[productData.productId]?.displayPrice ?? "..."
    }

    func isPurchased(_ productData: ShopProductData) -> Bool {
        productData.purchaseType == .nonConsumable
            && purchasedProductIds.contains(productData.productId)
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
    case purchased(ShopProductData)
    case pending
    case cancelled
    case failed(String)
}

private enum StorePurchaseError: Error {
    case unverified
}
