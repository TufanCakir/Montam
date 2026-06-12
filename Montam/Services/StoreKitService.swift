//
//  StoreKitService.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import StoreKit

@MainActor
class StoreKitService: ObservableObject {

    static let shared = StoreKitService()

    @Published var products: [Product] = []

    private init() {
        listenForTransactions()
    }

    func price(for id: String) -> String? {
        products.first(where: { $0.id == id })?.displayPrice
    }

    // MARK: - Products Laden
    func loadProducts(ids: [String]) async throws {
        products = try await Product.products(for: ids)
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    // MARK: - Kauf
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {

        case .success(let verification):
            let transaction = try checkVerified(verification)

            await transaction.finish()
            return true

        case .pending:
            print("⏳ Kauf ausstehend")
            return false

        case .userCancelled:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore
    func restore() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                await transaction.finish()
            }
        }
    }

    // MARK: - Verification
    private func checkVerified<T>(
        _ result: VerificationResult<T>
    ) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified:
            throw StoreError.failedVerification
        }
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
