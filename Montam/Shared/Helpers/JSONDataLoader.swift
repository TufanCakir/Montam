//
//  JSONDataLoader.swift
//  Monster Transorfmieren
//

import Foundation

enum JSONDataLoader {
    static func load<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
