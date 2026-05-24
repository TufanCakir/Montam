//
//  RemoteAssetManager.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Foundation

final class RemoteAssetManager {
    static let shared = RemoteAssetManager()

    private let folderName = "RemoteDrakonAssets"
    private let timeout: TimeInterval = 8

    private init() {
        migrateLegacyCacheIfNeeded()
    }

    func preload(manifest: RemoteManifest, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let baseURL = manifest.assetBaseURL.flatMap(URL.init(string:)) {
                self.preload(assets: manifest.assets, baseURL: baseURL)
            }

            if let musicBaseURL = manifest.musicBaseURL.flatMap(
                URL.init(string:)
            ) {
                self.preload(assets: manifest.music, baseURL: musicBaseURL)
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func localURL(for id: String) -> URL? {
        let directory = remoteDirectory()
        let matches =
            (try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: nil
            )) ?? []
        return matches.first {
            $0.deletingPathExtension().lastPathComponent == id
        }
    }

    func download(asset: RemoteAsset, baseURL: URL) -> Int {
        if let localURL = localURL(for: asset.id),
            let size = try? localURL.resourceValues(forKeys: [.fileSizeKey])
                .fileSize
        {
            return size
        }

        let remoteURL = baseURL.appendingPathComponent(asset.file)
        guard let data = fetchData(from: remoteURL) else { return 0 }
        save(data, id: asset.id, fileExtension: remoteURL.pathExtension)
        return data.count
    }

    func cachedAssetCount(in manifest: RemoteManifest) -> Int {
        (manifest.assets + manifest.music).filter {
            localURL(for: $0.id) != nil
        }.count
    }

    private func preload(assets: [RemoteAsset], baseURL: URL) {
        for asset in assets {
            guard localURL(for: asset.id) == nil else { continue }
            let remoteURL = baseURL.appendingPathComponent(asset.file)
            guard let data = fetchData(from: remoteURL) else {
                continue
            }
            save(
                data,
                id: asset.id,
                fileExtension: remoteURL.pathExtension
            )
        }
    }

    private func save(_ data: Data, id: String, fileExtension: String) {
        let directory = remoteDirectory()
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        let url = directory.appendingPathComponent(id).appendingPathExtension(
            fileExtension.isEmpty ? "png" : fileExtension
        )
        try? data.write(to: url, options: .atomic)
    }

    private func fetchData(from url: URL) -> Data? {
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

    private func remoteDirectory() -> URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(folderName, isDirectory: true)
    }

    private func legacyCacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName, isDirectory: true)
    }

    private func migrateLegacyCacheIfNeeded() {
        let fileManager = FileManager.default
        let legacyDirectory = legacyCacheDirectory()
        let destinationDirectory = remoteDirectory()

        guard fileManager.fileExists(atPath: legacyDirectory.path) else {
            return
        }

        try? fileManager.createDirectory(
            at: destinationDirectory,
            withIntermediateDirectories: true
        )

        let files =
            (try? fileManager.contentsOfDirectory(
                at: legacyDirectory,
                includingPropertiesForKeys: nil
            )) ?? []

        for file in files {
            let destination = destinationDirectory.appendingPathComponent(
                file.lastPathComponent
            )
            guard !fileManager.fileExists(atPath: destination.path) else {
                continue
            }
            try? fileManager.copyItem(at: file, to: destination)
        }
    }
}
