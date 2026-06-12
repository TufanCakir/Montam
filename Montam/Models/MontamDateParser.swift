//
//  MontamDateParser.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

enum MontamDateParser {
    static func date(from string: String?) -> Date? {
        guard let string else { return nil }

        if let isoDate = ISO8601DateFormatter().date(from: string) {
            return isoDate
        }

        return germanDateFormatter.date(from: string)
    }

    private static let germanDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.timeZone = TimeZone(identifier: "Europe/Berlin")
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()
}
