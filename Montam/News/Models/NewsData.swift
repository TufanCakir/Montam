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
    let date: String?
    let category: String?
}
