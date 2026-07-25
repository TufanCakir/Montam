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
    fileprivate static let backgroundJSONFileName = "background"

    private(set) var isUpdating = false
    private(set) var statusText: String?
    private(set) var completedFileCount = 0
    private(set) var totalFileCount = 1
    private(set) var downloadedBytes = 0

    var progress: Double {
        guard totalFileCount > 0 else {
            return 0
        }

        return min(Double(completedFileCount) / Double(totalFileCount), 1)
    }

    var progressText: String {
        "\(completedFileCount)/\(totalFileCount) Dateien • \(Self.megabyteText(downloadedBytes))"
    }

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

    nonisolated static func cachedAssetExists(named fileName: String) -> Bool {
        FileManager.default.fileExists(
            atPath: cachedAssetURL(named: fileName).path()
        )
    }

    nonisolated static func cachedMusicURL(named fileName: String) -> URL {
        cacheDirectory.appending(path: "Music/\(fileName)")
    }

    func updateAtLaunch(showOverlay: Bool = true) async {
        guard !isUpdating else {
            return
        }

        isUpdating = true

        completedFileCount = 0
        totalFileCount = 1
        downloadedBytes = 0

        if showOverlay {
            statusText = "Aktualisiere Inhalte"
        }

        defer {
            isUpdating = false

            if showOverlay {
                statusText = nil
            }
        }

        await updateRemoteConfig(showOverlay: showOverlay)

        let config = Self.loadRemoteConfig()
        guard config.isCompatibleWithCurrentApp else {
            if showOverlay {
                statusText = "App-Update erforderlich"
            }
            return
        }

        let plan = Self.contentUpdatePlan(config: config)
        prepareProgressTotal(plan: plan)

        await updateBackgroundFiles(
            plan: plan,
            config: config,
            showOverlay: showOverlay
        )
        await updateJSONFiles(
            plan: plan,
            showOverlay: showOverlay
        )

        await updateAssetFiles(
            plan: plan,
            config: config,
            showOverlay: showOverlay
        )

        await updateMusicFiles(
            plan: plan,
            showOverlay: showOverlay
        )
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

    private func updateRemoteConfig(showOverlay: Bool) async {
        if showOverlay {
            statusText = "Lade Konfiguration"
        }

        recordDownload(
            await Self.downloadJSON("remoteConfig", session: session)
        )
    }

    private func updateBackgroundFiles(
        plan: ContentUpdatePlan,
        config: RemoteContentConfig,
        showOverlay: Bool
    ) async {
        guard plan.jsonFiles.contains(Self.backgroundJSONFileName) else {
            return
        }

        if showOverlay {
            statusText = "Lade Hintergründe"
        }
        recordDownload(
            await Self.downloadJSON(
                Self.backgroundJSONFileName,
                session: session
            )
        )

        for assetName in Self.backgroundAssetNamesInOrder() {
            recordDownload(
                await Self.downloadAsset(
                    named: assetName,
                    extensions: config.resolvedAssetExtensions,
                    session: session
                )
            )
        }
    }

    private func updateJSONFiles(
        plan: ContentUpdatePlan,
        showOverlay: Bool
    ) async {

        if showOverlay {
            statusText = "Lade Daten"
        }

        for fileName in plan.regularJSONFiles {
            recordDownload(
                await Self.downloadJSON(fileName, session: session)
            )
        }
    }

    private func updateMusicFiles(
        plan: ContentUpdatePlan,
        showOverlay: Bool
    ) async {

        if showOverlay {
            statusText = "Lade Musik"
        }

        for fileName in plan.musicFiles.sorted() {
            recordDownload(
                await Self.downloadFile(
                    remoteURL: Self.musicURL.appending(path: fileName),
                    destinationURL: Self.cachedMusicURL(named: fileName),
                    session: session
                )
            )
        }
    }

    private func updateAssetFiles(
        plan: ContentUpdatePlan,
        config: RemoteContentConfig,
        showOverlay: Bool
    ) async {

        if showOverlay {
            statusText = "Lade Bilder"
        }

        for assetName in plan.regularAssetNames {
            recordDownload(
                await Self.downloadAsset(
                    named: assetName,
                    extensions: config.resolvedAssetExtensions,
                    session: session
                )
            )
        }
    }

    private func prepareProgressTotal(plan: ContentUpdatePlan) {
        totalFileCount =
            1
            + plan.jsonFiles.count
            + plan.assetNames.count
            + plan.musicFiles.count
    }

    private func recordDownload(_ result: FileDownloadResult) {
        completedFileCount += 1
        downloadedBytes += result.bytes
    }

    private static func downloadJSON(_ fileName: String, session: URLSession)
        async -> FileDownloadResult
    {
        let primaryURL = Self.rootURL.appending(path: "JSON/\(fileName).json")
        let fallbackURL = Self.rootURL.appending(path: "\(fileName).json")
        let destinationURL = Self.cachedJSONURL(for: fileName)

        let primaryResult = await downloadFile(
            remoteURL: primaryURL,
            destinationURL: destinationURL,
            session: session
        )
        if primaryResult.didDownload {
            return primaryResult
        }

        return await downloadFile(
            remoteURL: fallbackURL,
            destinationURL: destinationURL,
            session: session
        )
    }

    private static func downloadAsset(
        named fileName: String,
        extensions: [String],
        session: URLSession
    ) async -> FileDownloadResult {
        let destinationURL = Self.cachedAssetURL(named: fileName)

        if fileName.contains(".") {
            return await downloadFile(
                remoteURL: Self.assetsURL.appending(path: fileName),
                destinationURL: destinationURL,
                session: session
            )
        }

        for fileExtension in extensions {
            let remoteURL = Self.assetsURL.appending(
                path: "\(fileName).\(fileExtension)"
            )
            let result = await downloadFile(
                remoteURL: remoteURL,
                destinationURL: destinationURL,
                session: session
            )
            if result.didDownload {
                return result
            }
        }

        return .failed
    }

    @discardableResult
    private static func downloadFile(
        remoteURL: URL,
        destinationURL: URL,
        session: URLSession
    ) async -> FileDownloadResult {
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
                return .failed
            }

            try data.write(to: destinationURL, options: .atomic)
            return FileDownloadResult(didDownload: true, bytes: data.count)
        } catch {
            return .failed
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

    private static func contentUpdatePlan(
        config: RemoteContentConfig
    ) -> ContentUpdatePlan {
        let jsonFiles = config.resolvedJSONFiles
        let assetNames = Set(config.resolvedAssetFiles)
            .union(
                assetNamesFromCurrentJSON(
                    jsonFiles: jsonFiles,
                    assetKeys: Set(config.resolvedAssetKeys)
                )
            )
        let backgroundAssetNames = backgroundAssetNames()
        let configuredMusicFiles = config.resolvedMusicFiles
        let jsonMusicFiles =
            JSONDataLoader.load("music", as: [MusicData].self)?
            .map(\.file) ?? []
        let musicFiles = Set(configuredMusicFiles + jsonMusicFiles)

        return ContentUpdatePlan(
            jsonFiles: jsonFiles,
            assetNames: assetNames,
            backgroundAssetNames: backgroundAssetNames,
            musicFiles: musicFiles
        )
    }

    private static func backgroundAssetNames() -> Set<String> {
        Set(backgroundAssetNamesInOrder())
    }

    private static func backgroundAssetNamesInOrder() -> [String] {
        let backgrounds =
            JSONDataLoader.load(
                backgroundJSONFileName,
                as: [BackgroundData].self
            ) ?? []

        var seen = Set<String>()
        return backgrounds.compactMap(\.resolvedBackgroundImageName).filter {
            seen.insert($0).inserted
        }
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

    private static func megabyteText(_ bytes: Int) -> String {
        let megabytes = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", megabytes)
    }
}

private struct FileDownloadResult {
    let didDownload: Bool
    let bytes: Int

    static let failed = FileDownloadResult(didDownload: false, bytes: 0)
}

private struct ContentUpdatePlan {
    let jsonFiles: [String]
    let assetNames: Set<String>
    let backgroundAssetNames: Set<String>
    let musicFiles: Set<String>

    var regularJSONFiles: [String] {
        jsonFiles.filter { $0 != RemoteContentService.backgroundJSONFileName }
    }

    var regularAssetNames: [String] {
        assetNames
            .subtracting(backgroundAssetNames)
            .sorted()
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
