//
//  JSONLoader.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Foundation

final class JSONLoader {
    private static let remoteBaseURL = URL(
        string: "https://remotedrakon.tufancakir.com"
    )!
    private static let timeout: TimeInterval = 6

    static func load<T: Decodable>(_ file: String) throws -> T {
        let data = try data(for: file)
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func preload(_ files: [String], completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var filesToLoad = files
            let manifest: RemoteManifest? = try? load("remote_manifest")

            if let manifest {
                filesToLoad.append(contentsOf: manifest.jsonFiles)
            }

            for file in Set(filesToLoad) {
                _ = try? data(for: file)
            }

            DispatchQueue.main.async {
                if let manifest {
                    RemoteAssetManager.shared.preload(
                        manifest: manifest,
                        completion: completion
                    )
                } else {
                    completion()
                }
            }
        }
    }

    static func hasCachedData(for file: String) -> Bool {
        cachedData(for: file) != nil
    }

    static func cacheRemoteFile(_ file: String) -> Int {
        guard let remoteData = fetchRemoteData(for: file) else { return 0 }
        cache(remoteData, for: file)
        return remoteData.count
    }

    static func manifest() -> RemoteManifest {
        (try? load("remote_manifest"))
            ?? RemoteManifest(
                jsonFiles: [],
                assetBaseURL: nil,
                musicBaseURL: nil,
                assets: []
            )
    }

    private static func data(for file: String) throws -> Data {
        if let remoteData = fetchRemoteData(for: file) {
            cache(remoteData, for: file)
            return remoteData
        }

        if let cachedData = cachedData(for: file) {
            return cachedData
        }

        return try bundledData(for: file)
    }

    private static func fetchRemoteData(for file: String) -> Data? {
        let url = remoteBaseURL.appendingPathComponent("\(file).json")
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data?

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { semaphore.signal() }

            guard error == nil,
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode,
                let data,
                !data.isEmpty
            else {
                return
            }

            result = data
        }
        .resume()

        _ = semaphore.wait(timeout: .now() + timeout)
        return result
    }

    private static func bundledData(for file: String) throws -> Data {
        guard
            let url = Bundle.main.url(forResource: file, withExtension: "json")
        else {
            throw CocoaError(
                .fileNoSuchFile,
                userInfo: [
                    NSFilePathErrorKey: "\(file).json"
                ]
            )
        }

        return try Data(contentsOf: url)
    }

    private static func cache(_ data: Data, for file: String) {
        UserDefaults.standard.set(data, forKey: cacheKey(for: file))
    }

    private static func cachedData(for file: String) -> Data? {
        UserDefaults.standard.data(forKey: cacheKey(for: file))
    }

    private static func cacheKey(for file: String) -> String {
        "drakon_remote_json_\(file)"
    }
}
