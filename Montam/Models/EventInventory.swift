//
//  EventInventory.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class EventInventory: ObservableObject {

    static let shared = EventInventory()

    @Published var tokens: Int = 0

    private let key = "event_tokens"

    init() {

        tokens = UserDefaults.standard.integer(forKey: key)

    }

    func addTokens(_ amount: Int) {

        tokens += amount

        UserDefaults.standard.set(tokens, forKey: key)

    }
}
