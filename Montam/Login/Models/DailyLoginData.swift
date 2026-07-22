//
//  DailyLoginData.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct DailyLoginData: Codable, Identifiable {
    var id: Int { day }
    let day: Int
    let coins: Int
    let crystals: Int
    let bits: Int?
    let summonTickets: Int?
}
