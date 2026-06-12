//
//  GiftClaimManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class GiftClaimManager: ObservableObject {

    static let shared = GiftClaimManager()

    @Published private var claimed: Set<String> = []

    private let key = "claimed_gifts"

    private init() {
        load()
    }

    func reset() {
        claimed = []
        save()
    }

    func isClaimed(_ id: String) -> Bool {
        claimed.contains(id)
    }

    func claim(_ id: String) {
        claimed.insert(id)
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(claimed), forKey: key)
    }

    private func load() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        claimed = Set(saved)
    }
}
