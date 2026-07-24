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
    let singleCost: Int
    let multiCost: Int
    let bannerImage: String
}
