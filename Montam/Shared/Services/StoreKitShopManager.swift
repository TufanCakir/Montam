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
        let requestedIds = Set(uniqueIds)

        if !force, requestedProductIds == requestedIds,
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
            return
        }

        do {
            isLoadingProducts = true
            defer { isLoadingProducts = false }

            #if DEBUG
                debugPrintStoreKitRequest(uniqueIds)
            #endif

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

            #if DEBUG
                debugPrintStoreKitResponse(
                    requestedIds: uniqueIds,
                    products: products,
                    unavailableIds: unavailableProductIds
                )
            #endif

            await refreshEntitlements()
        } catch {
            isLoadingProducts = false
            productsById = [:]
            errorMessage = "Store konnte nicht geladen werden."
            unavailableProductIds = Set(uniqueIds)

            #if DEBUG
                print(
                    "StoreKit product loading failed for IDs: \(uniqueIds.joined(separator: ", "))"
                )
                print("StoreKit loading error: \(error)")
            #endif
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

            #if DEBUG
                print("========== STOREKIT PURCHASE DEBUG ==========")
                print("Starting purchase: \(productId)")
                print("Product type: \(product.type)")
                print("Display name: \(product.displayName)")
                print("Display price: \(product.displayPrice)")
                print("Was already entitled: \(wasPurchased)")
                print("=============================================")
            #endif

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verifiedTransaction(from: verification)
                await transaction.finish()

                #if DEBUG
                    print(
                        "StoreKit purchase verified: \(transaction.productID)"
                    )
                    print("StoreKit transaction id: \(transaction.id)")
                #endif

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
                #if DEBUG
                    print("StoreKit purchase pending: \(productId)")
                #endif
                return .pending

            case .userCancelled:
                #if DEBUG
                    print("StoreKit purchase cancelled: \(productId)")
                #endif
                return .cancelled

            @unknown default:
                #if DEBUG
                    print(
                        "StoreKit purchase returned unknown result: \(productId)"
                    )
                #endif
                return .failed("Unbekannter StoreKit-Status.")
            }
        } catch {
            #if DEBUG
                print("StoreKit purchase failed: \(productId)")
                print("StoreKit purchase error: \(error)")
            #endif
            return .failed("Kauf konnte nicht abgeschlossen werden.")
        }
    }

    func restorePurchases() async {
        do {
            #if DEBUG
                print("========== STOREKIT RESTORE DEBUG ==========")
                print("Starting AppStore.sync()")
                print("============================================")
            #endif

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

        #if DEBUG
            print("========== STOREKIT ENTITLEMENTS DEBUG ==========")
            print(
                "Current entitlements: \(purchasedProductIds.sorted().joined(separator: ", "))"
            )
            print("=================================================")
        #endif
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

    #if DEBUG
        private func debugPrintStoreKitRequest(_ productIds: [String]) {
            print("========== STOREKIT REQUEST DEBUG ==========")
            print("Bundle ID: \(Bundle.main.bundleIdentifier ?? "-")")
            print("Can make payments: \(AppStore.canMakePayments)")
            print("Requested count: \(productIds.count)")
            for productId in productIds {
                print("REQUEST \(debugProductIdLine(productId))")
            }
            print("============================================")
        }

        private func debugPrintStoreKitResponse(
            requestedIds: [String],
            products: [Product],
            unavailableIds: Set<String>
        ) {
            print("========== STOREKIT RESPONSE DEBUG ==========")
            print("Requested IDs:")
            requestedIds.forEach { print("  - \($0)") }

            print("Loaded products:")
            if products.isEmpty {
                print("  - none")
            } else {
                for product in products.sorted(by: { $0.id < $1.id }) {
                    print(
                        [
                            "id=\(product.id)",
                            "type=\(product.type)",
                            "name=\(product.displayName)",
                            "price=\(product.displayPrice)",
                            "description=\(product.description)",
                        ].joined(separator: " | ")
                    )
                }
            }

            print("Missing IDs:")
            if unavailableIds.isEmpty {
                print("  - none")
            } else {
                for productId in unavailableIds.sorted() {
                    print("  - \(debugProductIdLine(productId))")
                }
                print(
                    "Hinweis: StoreKit liefert keinen Grund pro fehlender ID. Wenn die ID hier fehlt, ist sie fuer diese Bundle-ID/Sandbox/ASC-Konfiguration nicht verfuegbar."
                )
            }
            print("=============================================")
        }

        private func debugProductIdLine(_ productId: String) -> String {
            let scalars = productId.unicodeScalars.map {
                "U+\(String($0.value, radix: 16, uppercase: true))"
            }
            .joined(separator: " ")

            return
                "'\(productId)' length=\(productId.count) scalars=[\(scalars)]"
        }
    #endif

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
