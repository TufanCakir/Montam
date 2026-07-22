//
//  TradeViewModel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Observation

@MainActor
@Observable
final class TradeViewModel {
    var offers: [TradeOfferData] = []
    var message: String?

    var sectionTitles: [String] {
        offers.reduce(into: []) { sections, offer in
            if !sections.contains(offer.section) {
                sections.append(offer.section)
            }
        }
    }

    func loadIfNeeded() {
        guard offers.isEmpty else {
            return
        }

        offers = (JSONDataLoader.load("trade", as: [TradeOfferData].self) ?? [])
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    func offers(in section: String) -> [TradeOfferData] {
        offers.filter { $0.section == section }
    }

    func showMessage(_ text: String) {
        message = text
        Task {
            try? await Task.sleep(for: .seconds(1.4))
            await MainActor.run {
                if message == text {
                    message = nil
                }
            }
        }
    }
}
