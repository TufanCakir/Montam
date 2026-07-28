//
//  TradeOfferData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct TradeOfferData: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let titleKey: String?
    let subtitleKey: String?
    let section: String
    let sectionKey: String?
    let costCurrency: String
    let costAmount: Int
    let rewardCurrency: String
    let rewardAmount: Int
    let sortOrder: Int

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedSubtitle: String? {
        if let subtitleKey {
            return AppLocalizationService.text(subtitleKey)
        }

        return subtitle
    }

    var localizedSection: String {
        if let sectionKey {
            return AppLocalizationService.text(sectionKey)
        }

        return section
    }
}
