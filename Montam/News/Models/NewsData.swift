//
//  NewsData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct NewsData: Codable, Identifiable {
    let id: String
    let title: String
    let message: String
    let titleKey: String?
    let messageKey: String?
    let date: String?
    let category: String?
    let categoryKey: String?

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }

    var localizedMessage: String {
        if let messageKey {
            return AppLocalizationService.text(messageKey)
        }

        return message
    }

    var localizedCategory: String? {
        if let categoryKey {
            return AppLocalizationService.text(categoryKey)
        }

        return category
    }
}
