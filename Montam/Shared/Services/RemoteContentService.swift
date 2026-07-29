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

    nonisolated private static let rootURL = URL(
        string: "https://remotemontam.tufancakir.com/"
    )!
    nonisolated private static let assetsURL = URL(
        string: "https://remotemontam.tufancakir.com/assets/"
    )!
    nonisolated private static let musicURL = URL(
        string: "https://remotemontam.tufancakir.com/music/"
    )!
    fileprivate static let backgroundJSONFileName = "background"
    private static let downloadedContentVersionKey =
        "RemoteContentService.downloadedContentVersion"

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
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
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

    func preloadForNavigation(
        jsonFiles: [String],
        additionalAssetKeys: Set<String> = [],
        includeConfiguredAssetFiles: Bool = false,
        includeMusic: Bool = false,
        showOverlay: Bool = true
    ) async {
        guard !isUpdating else {
            return
        }

        let config = Self.loadRemoteConfig()
        guard config.isCompatibleWithCurrentApp else {
            return
        }

        let configuredJSONFiles = Set(config.resolvedJSONFiles)
        let scopedJSONFiles =
            configuredJSONFiles.isEmpty
            ? jsonFiles
            : jsonFiles.filter { configuredJSONFiles.contains($0) }
        let plan = Self.contentUpdatePlan(
            config: config,
            jsonFiles: scopedJSONFiles,
            additionalAssetKeys: additionalAssetKeys,
            includeConfiguredAssetFiles: includeConfiguredAssetFiles,
            includeMusic: includeMusic
        )

        guard !Self.hasAllCachedFiles(plan: plan) else {
            return
        }

        isUpdating = true
        completedFileCount = 0
        totalFileCount = 1
        downloadedBytes = 0

        if showOverlay {
            statusText = "Lade Inhalte"
        }

        defer {
            isUpdating = false

            if showOverlay {
                statusText = nil
            }
        }

        prepareProgressTotal(plan: plan, includesRemoteConfig: false)

        _ = await updateBackgroundFiles(
            plan: plan,
            config: config,
            showOverlay: showOverlay,
            forceDownload: false
        )
        _ = await updateJSONFiles(
            plan: plan,
            showOverlay: showOverlay,
            forceDownload: false
        )

        let assetPlan = Self.contentUpdatePlan(
            config: config,
            jsonFiles: scopedJSONFiles,
            additionalAssetKeys: additionalAssetKeys,
            includeConfiguredAssetFiles: includeConfiguredAssetFiles,
            includeMusic: includeMusic
        )

        _ = await updateAssetFiles(
            plan: assetPlan,
            config: config,
            showOverlay: showOverlay,
            forceDownload: false
        )
        _ = await updateMusicFiles(
            plan: assetPlan,
            showOverlay: showOverlay,
            forceDownload: false
        )

        Self.invalidateLoadedContentCaches()
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

        let previousContentVersion = Self.downloadedContentVersion
        _ = await updateRemoteConfig(showOverlay: showOverlay)

        let config = Self.loadRemoteConfig()
        guard config.isCompatibleWithCurrentApp else {
            if showOverlay {
                statusText = "App-Update erforderlich"
            }
            return
        }

        let plan = Self.contentUpdatePlan(config: config)
        let didChangeContentVersion =
            config.contentVersion != nil
            && config.contentVersion != previousContentVersion
        let shouldRefreshContent = didChangeContentVersion

        if !shouldRefreshContent && Self.hasAllCachedFiles(plan: plan) {
            return
        }

        prepareProgressTotal(plan: plan)

        let didUpdateBackgrounds = await updateBackgroundFiles(
            plan: plan,
            config: config,
            showOverlay: showOverlay,
            forceDownload: shouldRefreshContent
        )
        let didUpdateJSON = await updateJSONFiles(
            plan: plan,
            showOverlay: showOverlay,
            forceDownload: shouldRefreshContent
        )

        let assetPlan = Self.contentUpdatePlan(config: config)

        let didUpdateAssets = await updateAssetFiles(
            plan: assetPlan,
            config: config,
            showOverlay: showOverlay,
            forceDownload: shouldRefreshContent
        )

        let didUpdateMusic = await updateMusicFiles(
            plan: assetPlan,
            showOverlay: showOverlay,
            forceDownload: shouldRefreshContent
        )
        let didCompleteContentUpdate =
            didUpdateBackgrounds
            && didUpdateJSON
            && didUpdateAssets
            && didUpdateMusic

        if let contentVersion = config.contentVersion,
            didCompleteContentUpdate
        {
            Self.downloadedContentVersion = contentVersion
        }

        Self.invalidateLoadedContentCaches()
    }

    static func clearCachedContent() {
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: cacheDirectory)
        createDirectoriesIfNeeded()
        invalidateLoadedContentCaches()
    }

    private static func invalidateLoadedContentCaches() {
        JSONDataLoader.invalidateCache()
        GameVisualCatalog.invalidate()
        RemoteAssetImage.invalidateCache()
        BattleTextureCache.invalidate()
    }

    func cachedAssetIfAvailable(named fileName: String) -> URL? {
        let url = Self.cachedAssetURL(named: fileName)
        return fileManager.fileExists(atPath: url.path()) ? url : nil
    }

    func cachedMusicIfAvailable(named fileName: String) -> URL? {
        let url = Self.cachedMusicURL(named: fileName)
        return fileManager.fileExists(atPath: url.path()) ? url : nil
    }

    private func updateRemoteConfig(showOverlay: Bool) async
        -> FileDownloadResult
    {
        if showOverlay {
            statusText = "Lade Konfiguration"
        }

        let result = await Self.downloadJSON(
            "remoteConfig",
            session: session,
            forceDownload: true
        )
        recordDownload(result)
        return result
    }

    private func updateBackgroundFiles(
        plan: ContentUpdatePlan,
        config: RemoteContentConfig,
        showOverlay: Bool,
        forceDownload: Bool
    ) async -> Bool {
        guard plan.jsonFiles.contains(Self.backgroundJSONFileName) else {
            return true
        }

        if showOverlay {
            statusText = "Lade Hintergründe"
        }
        let backgroundResult = await Self.downloadJSON(
            Self.backgroundJSONFileName,
            session: session,
            forceDownload: forceDownload
        )
        recordDownload(backgroundResult)
        var didSucceed = backgroundResult.didSucceed

        let session = self.session
        await withTaskGroup(of: FileDownloadResult.self) { group in
            for assetName in Self.backgroundAssetNamesInOrder() {
                group.addTask {
                    await Self.downloadAsset(
                        named: assetName,
                        extensions: config.resolvedAssetExtensions,
                        session: session,
                        forceDownload: forceDownload
                    )
                }
            }

            for await result in group {
                recordDownload(result)
                didSucceed = didSucceed && result.didSucceed
            }
        }

        return didSucceed
    }

    private func updateJSONFiles(
        plan: ContentUpdatePlan,
        showOverlay: Bool,
        forceDownload: Bool
    ) async -> Bool {

        if showOverlay {
            statusText = "Lade Daten"
        }

        var didSucceed = true
        let session = self.session
        await withTaskGroup(of: FileDownloadResult.self) { group in
            for fileName in plan.regularJSONFiles {
                group.addTask {
                    await Self.downloadJSON(
                        fileName,
                        session: session,
                        forceDownload: forceDownload
                    )
                }
            }

            for await result in group {
                recordDownload(result)
                didSucceed = didSucceed && result.didSucceed
            }
        }

        return didSucceed
    }

    private func updateMusicFiles(
        plan: ContentUpdatePlan,
        showOverlay: Bool,
        forceDownload: Bool
    ) async -> Bool {

        if showOverlay {
            statusText = "Lade Musik"
        }

        var didSucceed = true
        let session = self.session
        await withTaskGroup(of: FileDownloadResult.self) { group in
            for fileName in plan.musicFiles {
                group.addTask {
                    await Self.downloadFile(
                        remoteURL: Self.musicURL.appending(path: fileName),
                        destinationURL: Self.cachedMusicURL(named: fileName),
                        session: session,
                        forceDownload: forceDownload
                    )
                }
            }

            for await result in group {
                recordDownload(result)
                didSucceed = didSucceed && result.didSucceed
            }
        }

        return didSucceed
    }

    private func updateAssetFiles(
        plan: ContentUpdatePlan,
        config: RemoteContentConfig,
        showOverlay: Bool,
        forceDownload: Bool
    ) async -> Bool {

        if showOverlay {
            statusText = "Lade Bilder"
        }

        var didSucceed = true
        let session = self.session
        await withTaskGroup(of: FileDownloadResult.self) { group in
            for assetName in plan.regularAssetNames {
                group.addTask {
                    await Self.downloadAsset(
                        named: assetName,
                        extensions: config.resolvedAssetExtensions,
                        session: session,
                        forceDownload: forceDownload
                    )
                }
            }

            for await result in group {
                recordDownload(result)
                didSucceed = didSucceed && result.didSucceed
            }
        }

        return didSucceed
    }

    private func prepareProgressTotal(
        plan: ContentUpdatePlan,
        includesRemoteConfig: Bool = true
    ) {
        totalFileCount =
            (includesRemoteConfig ? 1 : 0)
            + plan.jsonFiles.count
            + plan.assetNames.count
            + plan.musicFiles.count
    }

    private func recordDownload(_ result: FileDownloadResult) {
        completedFileCount = min(completedFileCount + 1, totalFileCount)
        downloadedBytes += result.bytes
    }

    nonisolated private static func downloadJSON(
        _ fileName: String,
        session: URLSession,
        forceDownload: Bool
    )
        async -> FileDownloadResult
    {
        let primaryURL = Self.rootURL.appending(path: "JSON/\(fileName).json")
        let fallbackURL = Self.rootURL.appending(path: "\(fileName).json")
        let destinationURL = Self.cachedJSONURL(for: fileName)

        let primaryResult = await downloadFile(
            remoteURL: primaryURL,
            destinationURL: destinationURL,
            session: session,
            forceDownload: forceDownload
        )
        if primaryResult.didSucceed {
            return primaryResult
        }

        return await downloadFile(
            remoteURL: fallbackURL,
            destinationURL: destinationURL,
            session: session,
            forceDownload: forceDownload
        )
    }

    nonisolated private static func downloadAsset(
        named fileName: String,
        extensions: [String],
        session: URLSession,
        forceDownload: Bool
    ) async -> FileDownloadResult {
        let destinationURL = Self.cachedAssetURL(named: fileName)

        if !forceDownload,
            FileManager.default.fileExists(atPath: destinationURL.path())
        {
            return .skipped
        }

        if fileName.contains(".") {
            let result = await downloadFile(
                remoteURL: Self.assetsURL.appending(path: fileName),
                destinationURL: destinationURL,
                session: session,
                forceDownload: forceDownload
            )
            if forceDownload && !result.didSucceed {
                removeCachedFile(at: destinationURL)
            }
            return result
        }

        for fileExtension in extensions {
            let remoteURL = Self.assetsURL.appending(
                path: "\(fileName).\(fileExtension)"
            )
            let result = await downloadFile(
                remoteURL: remoteURL,
                destinationURL: destinationURL,
                session: session,
                forceDownload: forceDownload
            )
            if result.didDownload {
                return result
            }
        }

        if forceDownload {
            removeCachedFile(at: destinationURL)
        }
        return .failed
    }

    @discardableResult
    nonisolated private static func downloadFile(
        remoteURL: URL,
        destinationURL: URL,
        session: URLSession,
        forceDownload: Bool
    ) async -> FileDownloadResult {
        if !forceDownload,
            FileManager.default.fileExists(atPath: destinationURL.path())
        {
            return .skipped
        }

        do {
            var request = URLRequest(
                url: forceDownload ? cacheBustedURL(remoteURL) : remoteURL,
                cachePolicy: .reloadIgnoringLocalCacheData,
                timeoutInterval: 8
            )
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.setValue("no-cache", forHTTPHeaderField: "Pragma")
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                (200..<300).contains(httpResponse.statusCode)
            else {
                if forceDownload {
                    let statusCode =
                        (response as? HTTPURLResponse)?.statusCode ?? -1
                    print(
                        "RemoteContent failed:",
                        remoteURL.absoluteString,
                        "status:",
                        statusCode
                    )
                }
                return .failed
            }

            try data.write(to: destinationURL, options: .atomic)
            if forceDownload {
                print(
                    "RemoteContent downloaded:",
                    remoteURL.absoluteString,
                    "->",
                    destinationURL.lastPathComponent,
                    "\(data.count) bytes"
                )
            }
            return FileDownloadResult(
                didDownload: true,
                didSucceed: true,
                bytes: data.count
            )
        } catch {
            if forceDownload {
                print(
                    "RemoteContent error:",
                    remoteURL.absoluteString,
                    error.localizedDescription
                )
            }
            return .failed
        }
    }

    nonisolated private static func cacheBustedURL(_ url: URL) -> URL {
        guard
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
        else {
            return url
        }

        var queryItems = components.queryItems ?? []
        queryItems.append(
            URLQueryItem(
                name: "v",
                value: String(Int(Date().timeIntervalSince1970))
            )
        )
        components.queryItems = queryItems
        return components.url ?? url
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

    nonisolated private static func removeCachedFile(at url: URL) {
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return
        }

        try? FileManager.default.removeItem(at: url)
    }

    private static func loadRemoteConfig() -> RemoteContentConfig {
        JSONDataLoader.load("remoteConfig", as: RemoteContentConfig.self)
            ?? RemoteContentConfig()
    }

    private static func hasAllCachedFiles(plan: ContentUpdatePlan) -> Bool {
        let hasJSONFiles = plan.jsonFiles.allSatisfy {
            FileManager.default.fileExists(
                atPath: cachedJSONURL(for: $0).path()
            )
        }
        let hasAssetFiles = plan.assetNames.allSatisfy {
            FileManager.default.fileExists(
                atPath: cachedAssetURL(named: $0).path()
            )
        }
        let hasMusicFiles = plan.musicFiles.allSatisfy {
            FileManager.default.fileExists(
                atPath: cachedMusicURL(named: $0).path()
            )
        }

        return hasJSONFiles && hasAssetFiles && hasMusicFiles
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
        contentUpdatePlan(
            config: config,
            jsonFiles: config.resolvedJSONFiles,
            additionalAssetKeys: [],
            includeConfiguredAssetFiles: true,
            includeMusic: true
        )
    }

    private static func contentUpdatePlan(
        config: RemoteContentConfig,
        jsonFiles: [String],
        additionalAssetKeys: Set<String>,
        includeConfiguredAssetFiles: Bool,
        includeMusic: Bool
    ) -> ContentUpdatePlan {
        let assetKeys = Set(config.resolvedAssetKeys)
            .union(additionalAssetKeys)
        let configuredAssetNames =
            includeConfiguredAssetFiles
            ? Set(config.resolvedAssetFiles)
            : []
        let backgroundAssetNames =
            jsonFiles.contains(backgroundJSONFileName)
            ? backgroundAssetNames()
            : []
        let assetNames = configuredAssetNames
            .union(
                assetNamesFromCurrentJSON(
                    jsonFiles: jsonFiles,
                    assetKeys: assetKeys
                )
            )
            .union(backgroundAssetNames)
        let configuredMusicFiles =
            includeMusic ? config.resolvedMusicFiles : []
        let jsonMusicFiles: [String] =
            includeMusic
            ? (JSONDataLoader.load("music", as: [MusicData].self)?
                .map(\.file) ?? [])
            : []
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
        return backgrounds.flatMap(\.resolvedEnvironmentImageNames).filter {
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

    private static var downloadedContentVersion: Int? {
        get {
            let value = UserDefaults.standard.integer(
                forKey: downloadedContentVersionKey
            )
            return value == 0 ? nil : value
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: downloadedContentVersionKey
            )
        }
    }
}

private struct FileDownloadResult: Sendable {
    let didDownload: Bool
    let didSucceed: Bool
    let bytes: Int

    nonisolated static let failed = FileDownloadResult(
        didDownload: false,
        didSucceed: false,
        bytes: 0
    )
    nonisolated static let skipped = FileDownloadResult(
        didDownload: false,
        didSucceed: true,
        bytes: 0
    )
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
