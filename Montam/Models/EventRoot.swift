//
//  EventRoot.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

struct EventRoot: Codable {
    var categories: [EventCategoryInfo]
    var events: [GameEvent]
}
