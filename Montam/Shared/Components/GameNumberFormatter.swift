//
//  GameNumberFormatter.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum GameNumberFormatter {
    static func compact(_ value: Int) -> String {
        let absoluteValue = abs(value)

        if absoluteValue >= 1_000_000 {
            return scaled(value, by: 1_000_000, suffix: "M")
        }

        if absoluteValue >= 1_000 {
            return scaled(value, by: 1_000, suffix: "K")
        }

        return "\(value)"
    }

    private static func scaled(_ value: Int, by divisor: Double, suffix: String)
        -> String
    {
        let scaledValue = Double(value) / divisor
        let format =
            scaledValue.rounded() == scaledValue ? "%.0f %@" : "%.1f %@"
        return String(format: format, scaledValue, suffix)
    }
}
