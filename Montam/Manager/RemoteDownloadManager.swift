//
//  RemoteDownloadManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class RemoteDownloadManager: ObservableObject {
    static let shared = RemoteDownloadManager()

    @Published private(set) var manifest = RemoteManifest(
        jsonFiles: [],
        assetBaseURL: nil,
        musicBaseURL: nil,
        assets: []
    )
    @Published private(set) var progress: Double = 0
    @Published private(set) var downloadedBytes: Int = 0
    @Published private(set) var totalItems: Int = 0
    @Published private(set) var completedItems: Int = 0
    @Published private(set) var statusText: String = "Bereit"
    @Published private(set) var isLoading = false

    private init() {}

    func refreshManifest() {
        manifest = JSONLoader.manifest()
        totalItems =
            Set(manifest.jsonFiles).count + manifest.assets.count
            + manifest.music.count
        completedItems = cachedItemCount()
        progress =
            totalItems == 0 ? 0 : Double(completedItems) / Double(totalItems)
        downloadedBytes = 0
        statusText =
            hasCompleteCache
            ? "Remote Daten bereit" : "Remote Paket: \(totalItems) Dateien"
    }

    var hasCompleteCache: Bool {
        totalItems > 0 && completedItems >= totalItems
    }

    var hasBootCache: Bool {
        !manifest.jsonFiles.isEmpty
            && manifest.jsonFiles.allSatisfy {
                JSONLoader.hasCachedData(for: $0)
            }
            && JSONLoader.hasCachedData(for: "remote_manifest")
    }

    func preload(completion: @escaping () -> Void) {
        run(downloadAssets: false, completion: completion)
    }

    func downloadAll(completion: @escaping () -> Void) {
        run(downloadAssets: true, completion: completion)
    }

    func checkForUpdate(completion: @escaping (Bool) -> Void) {
        statusText = "Prüfe Remote Update"

        DispatchQueue.global(qos: .userInitiated).async {
            let hasUpdate = JSONLoader.remoteFileDiffersFromCache(
                "remote_manifest"
            )

            DispatchQueue.main.async {
                self.statusText =
                    hasUpdate ? "Update verfügbar" : "Remote Daten aktuell"
                completion(hasUpdate)
            }
        }
    }

    func clearCache() {
        JSONLoader.clearCache()
        RemoteAssetManager.shared.clearCache()
        refreshManifest()
    }

    private func run(downloadAssets: Bool, completion: @escaping () -> Void) {
        isLoading = true
        downloadedBytes = 0
        completedItems = 0
        progress = 0
        statusText =
            downloadAssets
            ? "Lade komplette Remote Daten" : "Preload JSON Daten"

        DispatchQueue.global(qos: .userInitiated).async {
            _ = JSONLoader.cacheRemoteFile("remote_manifest")
            let manifest = JSONLoader.manifest()
            let jsonFiles = Array(Set(manifest.jsonFiles + ["remote_manifest"]))
            let remoteFileCount =
                downloadAssets
                ? manifest.assets.count + manifest.music.count
                : 0
            let total = max(1, jsonFiles.count + remoteFileCount)
            var completed = 0
            var bytes = 0

            DispatchQueue.main.async {
                self.manifest = manifest
                self.totalItems = total
            }

            for file in jsonFiles {
                bytes += JSONLoader.cacheRemoteFile(file)
                completed += 1
                self.publish(
                    completed: completed,
                    total: total,
                    bytes: bytes,
                    status: "\(file).json"
                )
            }

            if downloadAssets,
                let baseURL = manifest.assetBaseURL.flatMap(URL.init(string:))
            {
                let result = self.download(
                    manifest.assets,
                    baseURL: baseURL,
                    completed: completed,
                    total: total,
                    bytes: bytes
                )
                completed = result.completed
                bytes = result.bytes
            }

            if downloadAssets,
                let musicBaseURL = manifest.musicBaseURL.flatMap(
                    URL.init(string:)
                )
            {
                let result = self.download(
                    manifest.music,
                    baseURL: musicBaseURL,
                    completed: completed,
                    total: total,
                    bytes: bytes
                )
                completed = result.completed
                bytes = result.bytes
            }

            DispatchQueue.main.async {
                self.isLoading = false
                self.statusText = "Fertig: \(self.formattedBytes(bytes))"
                completion()
            }
        }
    }

    private func cachedItemCount() -> Int {
        let cachedJSON = manifest.jsonFiles.filter {
            JSONLoader.hasCachedData(for: $0)
        }.count
        let cachedAssets = RemoteAssetManager.shared.cachedAssetCount(
            in: manifest
        )
        return cachedJSON + cachedAssets
    }

    private func publish(completed: Int, total: Int, bytes: Int, status: String)
    {
        DispatchQueue.main.async {
            self.completedItems = completed
            self.totalItems = total
            self.downloadedBytes = bytes
            self.progress = Double(completed) / Double(total)
            self.statusText = status
        }
    }

    private func download(
        _ assets: [RemoteAsset],
        baseURL: URL,
        completed: Int,
        total: Int,
        bytes: Int
    ) -> (completed: Int, bytes: Int) {
        var completed = completed
        var bytes = bytes

        for asset in assets {
            bytes += RemoteAssetManager.shared.download(
                asset: asset,
                baseURL: baseURL
            )
            completed += 1
            publish(
                completed: completed,
                total: total,
                bytes: bytes,
                status: asset.file
            )
        }

        return (completed, bytes)
    }

    func formattedBytes(_ bytes: Int) -> String {
        ByteCountFormatter.string(
            fromByteCount: Int64(bytes),
            countStyle: .file
        )
    }
}
