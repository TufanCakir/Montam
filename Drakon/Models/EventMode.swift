//
//  EventMode.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

enum EventMode: String, Codable {
    case main

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "main", "island":
            self = .main
        default:
            self = .main
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
