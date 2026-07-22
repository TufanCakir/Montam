import Foundation

enum GameNumberFormatter {
    static func compact(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1f M", Double(value) / 1_000_000)
        }

        if value >= 1_000 {
            return String(format: "%.1f K", Double(value) / 1_000)
        }

        return "\(value)"
    }
}
