//
//  RemoteContentService.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class RemoteContentService {
    static let shared = RemoteContentService()

    private static let rootURL = URL(
        string: "https://remotemontam.tufancakir.com/"
    )!
    private static let assetsURL = URL(
        string: "https://remotemontam.tufancakir.com/assets/"
    )!
    private static let musicURL = URL(
        string: "https://remotemontam.tufancakir.com/music/"
    )!

    private(set) var isUpdating = false
    private(set) var statusText: String?

    private let session: URLSession
    private let fileManager = FileManager.default

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 250 * 1024 * 1024
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: configuration)
        Self.createDirectoriesIfNeeded()
    }

    nonisolated static func cachedJSONURL(for fileName: String) -> URL {
        cacheDirectory.appending(path: "JSON/\(fileName).json")
    }

    nonisolated static func cachedAssetURL(named fileName: String) -> URL {
        cacheDirectory.appending(path: "Assets/\(fileName)")
    }

    nonisolated static func cachedMusicURL(named fileName: String) -> URL {
        cacheDirectory.appending(path: "Music/\(fileName)")
    }

    func updateAtLaunch() async {
        guard !isUpdating else {
            return
        }

        isUpdating = true
        statusText = "Aktualisiere Inhalte"
        defer {
            isUpdating = false
            statusText = nil
        }

        await updateRemoteConfig()

        let config = Self.loadRemoteConfig()
        guard config.isCompatibleWithCurrentApp else {
            statusText = "App-Update erforderlich"
            return
        }

        await updateJSONFiles(config: config)
        await updateAssetFiles(config: config)
        await updateMusicFiles(config: config)
    }

    nonisolated static func clearCachedContent() {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: cacheDirectory)
        createDirectoriesIfNeeded()
    }

    func cachedAssetIfAvailable(named fileName: String) -> URL? {
        let url = Self.cachedAssetURL(named: fileName)
        return fileManager.fileExists(atPath: url.path()) ? url : nil
    }

    func cachedMusicIfAvailable(named fileName: String) -> URL? {
        let url = Self.cachedMusicURL(named: fileName)
        return fileManager.fileExists(atPath: url.path()) ? url : nil
    }

    private func updateRemoteConfig() async {
        await Self.downloadJSON("remoteConfig", session: session)
    }

    private func updateJSONFiles(config: RemoteContentConfig) async {
        await withTaskGroup(of: Void.self) { group in
            for fileName in config.resolvedJSONFiles {
                group.addTask { [session] in
                    await Self.downloadJSON(fileName, session: session)
                }
            }
        }
    }

    private func updateMusicFiles(config: RemoteContentConfig) async {
        let configuredFiles = config.resolvedMusicFiles
        let jsonFiles =
            JSONDataLoader.load("music", as: [MusicData].self)?
            .map(\.file) ?? []
        let musicFiles = Set(configuredFiles + jsonFiles)

        await withTaskGroup(of: Void.self) { group in
            for fileName in musicFiles {
                group.addTask { [session] in
                    await Self.downloadFile(
                        remoteURL: Self.musicURL.appending(path: fileName),
                        destinationURL: Self.cachedMusicURL(named: fileName),
                        session: session
                    )
                }
            }
        }
    }

    private func updateAssetFiles(config: RemoteContentConfig) async {
        let assetNames = Set(config.resolvedAssetFiles)
            .union(
                Self.assetNamesFromCurrentJSON(
                    jsonFiles: config.resolvedJSONFiles,
                    assetKeys: Set(config.resolvedAssetKeys)
                )
            )

        await withTaskGroup(of: Void.self) { group in
            for assetName in assetNames {
                group.addTask { [session] in
                    await Self.downloadAsset(
                        named: assetName,
                        extensions: config.resolvedAssetExtensions,
                        session: session
                    )
                }
            }
        }
    }

    private static func downloadJSON(_ fileName: String, session: URLSession)
        async
    {
        let primaryURL = Self.rootURL.appending(path: "JSON/\(fileName).json")
        let fallbackURL = Self.rootURL.appending(path: "\(fileName).json")
        let destinationURL = Self.cachedJSONURL(for: fileName)

        if await downloadFile(
            remoteURL: primaryURL,
            destinationURL: destinationURL,
            session: session
        ) {
            return
        }

        _ = await downloadFile(
            remoteURL: fallbackURL,
            destinationURL: destinationURL,
            session: session
        )
    }

    private static func downloadAsset(
        named fileName: String,
        extensions: [String],
        session: URLSession
    ) async {
        let destinationURL = Self.cachedAssetURL(named: fileName)

        if fileName.contains(".") {
            _ = await downloadFile(
                remoteURL: Self.assetsURL.appending(path: fileName),
                destinationURL: destinationURL,
                session: session
            )
            return
        }

        for fileExtension in extensions {
            let remoteURL = Self.assetsURL.appending(
                path: "\(fileName).\(fileExtension)"
            )
            if await downloadFile(
                remoteURL: remoteURL,
                destinationURL: destinationURL,
                session: session
            ) {
                return
            }
        }
    }

    @discardableResult
    private static func downloadFile(
        remoteURL: URL,
        destinationURL: URL,
        session: URLSession
    ) async -> Bool {
        do {
            let request = URLRequest(
                url: remoteURL,
                cachePolicy: .reloadRevalidatingCacheData,
                timeoutInterval: 8
            )
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                return false
            }

            try data.write(to: destinationURL, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    nonisolated private static func createDirectoriesIfNeeded() {
        let fileManager = FileManager.default

        try? fileManager.createDirectory(
            at: cacheDirectory.appending(path: "JSON"),
            withIntermediateDirectories: true
        )
        try? fileManager.createDirectory(
            at: cacheDirectory.appending(path: "Assets"),
            withIntermediateDirectories: true
        )
        try? fileManager.createDirectory(
            at: cacheDirectory.appending(path: "Music"),
            withIntermediateDirectories: true
        )
    }

    private static func loadRemoteConfig() -> RemoteContentConfig {
        JSONDataLoader.load("remoteConfig", as: RemoteContentConfig.self)
            ?? RemoteContentConfig()
    }

    private static func assetNamesFromCurrentJSON(
        jsonFiles: [String],
        assetKeys: Set<String>
    ) -> Set<String> {
        var names = Set<String>()

        for fileName in jsonFiles {
            guard let data = jsonData(for: fileName),
                let object = try? JSONSerialization.jsonObject(with: data)
            else {
                continue
            }

            collectAssetNames(from: object, assetKeys: assetKeys, into: &names)
        }

        return names.filter { !$0.isEmpty && !$0.hasPrefix("http") }
    }

    private static func collectAssetNames(
        from object: Any,
        assetKeys: Set<String>,
        into names: inout Set<String>
    ) {
        if let dictionary = object as? [String: Any] {
            for (key, value) in dictionary {
                if assetKeys.contains(key),
                    let value = value as? String,
                    !value.isEmpty
                {
                    names.insert(value)
                } else {
                    collectAssetNames(
                        from: value,
                        assetKeys: assetKeys,
                        into: &names
                    )
                }
            }
            return
        }

        if let array = object as? [Any] {
            for item in array {
                collectAssetNames(
                    from: item,
                    assetKeys: assetKeys,
                    into: &names
                )
            }
        }
    }

    private static func jsonData(for fileName: String) -> Data? {
        let cachedURL = cachedJSONURL(for: fileName)
        if FileManager.default.fileExists(atPath: cachedURL.path()) {
            return try? Data(contentsOf: cachedURL)
        }

        guard
            let bundledURL = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
            return nil
        }

        return try? Data(contentsOf: bundledURL)
    }

    nonisolated private static var cacheDirectory: URL {
        let base = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]
        return base.appending(path: "RemoteMontam")
    }
}

private struct RemoteContentConfig: Codable {
    let contentVersion: Int?
    let minimumAppVersion: String?
    let notes: String?
    let jsonFiles: [String]?
    let assetFiles: [String]?
    let musicFiles: [String]?
    let assetExtensions: [String]?
    let assetKeys: [String]?

    init(
        contentVersion: Int? = nil,
        minimumAppVersion: String? = nil,
        notes: String? = nil,
        jsonFiles: [String]? = nil,
        assetFiles: [String]? = nil,
        musicFiles: [String]? = nil,
        assetExtensions: [String]? = nil,
        assetKeys: [String]? = nil
    ) {
        self.contentVersion = contentVersion
        self.minimumAppVersion = minimumAppVersion
        self.notes = notes
        self.jsonFiles = jsonFiles
        self.assetFiles = assetFiles
        self.musicFiles = musicFiles
        self.assetExtensions = assetExtensions
        self.assetKeys = assetKeys
    }

    var resolvedJSONFiles: [String] {
        jsonFiles ?? []
    }

    var resolvedAssetFiles: [String] {
        assetFiles ?? []
    }

    var resolvedMusicFiles: [String] {
        musicFiles ?? []
    }

    var resolvedAssetExtensions: [String] {
        assetExtensions ?? ["png"]
    }

    var resolvedAssetKeys: [String] {
        assetKeys ?? []
    }

    var isCompatibleWithCurrentApp: Bool {
        guard let minimumAppVersion, !minimumAppVersion.isEmpty else {
            return true
        }

        return AppBundleInfo.appVersion.compareSemanticVersion(
            minimumAppVersion
        ) != .orderedAscending
    }
}

extension String {
    fileprivate func compareSemanticVersion(_ other: String) -> ComparisonResult
    {
        let left = semanticVersionParts
        let right = other.semanticVersionParts
        let count = max(left.count, right.count)

        for index in 0..<count {
            let leftValue = index < left.count ? left[index] : 0
            let rightValue = index < right.count ? right[index] : 0

            if leftValue < rightValue {
                return .orderedAscending
            }

            if leftValue > rightValue {
                return .orderedDescending
            }
        }

        return .orderedSame
    }

    private var semanticVersionParts: [Int] {
        split(separator: ".").map { Int($0) ?? 0 }
    }
}
