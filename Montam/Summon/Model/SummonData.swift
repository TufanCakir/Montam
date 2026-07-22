//
//  SummonData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct SummonData: Codable {
    let id: String
    let title: String
    let category: String
    let currency: String
    let bannerImage: String?
    let renderMode: String?
    let accentColor: String?
    let iconShape: String?
    let description: String?
    let singleCost: Int?
    let multiCost: Int?
    let guaranteedAfter: Int?
}
