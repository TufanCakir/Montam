//
//  SummonCategoryData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct SummonCategoryData: Codable, Identifiable {
    let id: String
    let title: String
    let titleKey: String?

    var localizedTitle: String {
        if let titleKey {
            return AppLocalizationService.text(titleKey)
        }

        return title
    }
}
