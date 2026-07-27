//
//  JSONDataLoader.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

enum JSONDataLoader {
    private static let cache = JSONDataCache()

    static func load<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        if let cachedFile = sourceURL(for: fileName, cachedOnly: true),
            let cached: T = load(fileName, as: type, from: cachedFile)
        {
            return cached
        }

        guard let bundledFile = sourceURL(for: fileName, cachedOnly: false)
        else {
            return nil
        }

        return load(fileName, as: type, from: bundledFile)
    }

    static func invalidateCache() {
        cache.removeAll()
    }

    private static func load<T: Decodable>(
        _ fileName: String,
        as type: T.Type,
        from url: URL
    ) -> T? {
        let signature = fileSignature(for: url)
        let key = "\(fileName)|\(T.self)"

        if let cached: T = cache.value(for: key, signature: signature) {
            return cached
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(T.self, from: data)
            cache.insert(decoded, for: key, signature: signature)
            return decoded
        } catch {
            return nil
        }
    }

    private static func sourceURL(for fileName: String, cachedOnly: Bool)
        -> URL?
    {
        let url = RemoteContentService.cachedJSONURL(for: fileName)
        if FileManager.default.fileExists(atPath: url.path()) {
            return url
        }

        guard !cachedOnly else {
            return nil
        }

        return Bundle.main.url(forResource: fileName, withExtension: "json")
    }

    private static func fileSignature(for url: URL) -> JSONDataCache.Signature {
        let values = try? url.resourceValues(forKeys: [
            .contentModificationDateKey,
            .fileSizeKey,
        ])

        return JSONDataCache.Signature(
            modifiedAt: values?.contentModificationDate?.timeIntervalSince1970,
            fileSize: values?.fileSize
        )
    }
}

private final class JSONDataCache {
    struct Signature: Equatable {
        let modifiedAt: TimeInterval?
        let fileSize: Int?
    }

    private struct Entry {
        let signature: Signature
        let value: Any
    }

    private let lock = NSLock()
    private var entries: [String: Entry] = [:]

    func value<T>(for key: String, signature: Signature) -> T? {
        lock.lock()
        defer { lock.unlock() }

        guard let entry = entries[key], entry.signature == signature else {
            return nil
        }

        return entry.value as? T
    }

    func insert<T>(_ value: T, for key: String, signature: Signature) {
        lock.lock()
        entries[key] = Entry(signature: signature, value: value)
        lock.unlock()
    }

    func removeAll() {
        lock.lock()
        entries.removeAll()
        lock.unlock()
    }
}
