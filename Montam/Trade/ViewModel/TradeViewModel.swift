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
    private var offersBySection: [String: [TradeOfferData]] = [:]
    private var loadedSectionTitles: [String] = []

    var sectionTitles: [String] {
        loadedSectionTitles
    }

    func loadIfNeeded() {
        guard offers.isEmpty else {
            return
        }

        let loadedOffers =
            (JSONDataLoader.load(
                "trade",
                as: [TradeOfferData].self
            ) ?? [])
            .sorted { $0.sortOrder < $1.sortOrder }
        offers = loadedOffers
        offersBySection = Dictionary(grouping: loadedOffers) { $0.section }
        loadedSectionTitles = loadedOffers.reduce(into: []) {
            sections,
            offer in
            if !sections.contains(offer.section) {
                sections.append(offer.section)
            }
        }
    }

    func offers(in section: String) -> [TradeOfferData] {
        offersBySection[section] ?? []
    }

    func sectionTitle(for section: String) -> String {
        offersBySection[section]?.first?.localizedSection ?? section
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
