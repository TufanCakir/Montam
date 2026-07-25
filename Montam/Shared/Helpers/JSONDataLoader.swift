//
//  JSONDataLoader.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum JSONDataLoader {
    static func load<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        if let cached = loadCached(fileName, as: type) {
            return cached
        }

        return loadBundled(fileName, as: type)
    }

    private static func loadBundled<T: Decodable>(
        _ fileName: String,
        as type: T.Type
    ) -> T? {
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }

    private static func loadCached<T: Decodable>(
        _ fileName: String,
        as type: T.Type
    ) -> T? {
        let url = RemoteContentService.cachedJSONURL(for: fileName)

        guard FileManager.default.fileExists(atPath: url.path()) else {
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
