//
//  BattleMusicPlayer.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import AVFoundation
import Foundation

final class BattleMusicPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = BattleMusicPlayer()

    private var playlist: [URL] = []
    private var player: AVAudioPlayer?
    private var settingsObserver: NSObjectProtocol?
    private var currentIndex = 0
    private var currentFileNames: [String] = []

    private override init() {
        super.init()
        settingsObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyMusicSetting()
        }
    }

    deinit {
        if let settingsObserver {
            NotificationCenter.default.removeObserver(settingsObserver)
        }
    }

    func configure(fileNames: [String]) {
        let uniqueFileNames = fileNames.reduce(into: [String]()) {
            result,
            name in
            guard !result.contains(name) else {
                return
            }

            result.append(name)
        }

        guard uniqueFileNames != currentFileNames else {
            applyMusicSetting()
            return
        }

        currentFileNames = uniqueFileNames
        playlist = uniqueFileNames.compactMap(Self.audioURL(for:))
        currentIndex = min(currentIndex, max(playlist.count - 1, 0))
        applyMusicSetting()
    }

    func startIfNeeded() {
        guard isMusicEnabled, player == nil, !playlist.isEmpty else {
            return
        }

        play(at: currentIndex, attempts: 0)
    }

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        guard isMusicEnabled else {
            stop()
            return
        }

        playNext()
    }

    private func play(at index: Int, attempts: Int) {
        guard isMusicEnabled, !playlist.isEmpty else {
            return
        }

        guard attempts < playlist.count else {
            player = nil
            return
        }

        currentIndex = index % playlist.count

        do {
            let player = try AVAudioPlayer(contentsOf: playlist[currentIndex])
            player.delegate = self
            player.numberOfLoops = 0
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            currentIndex = (currentIndex + 1) % playlist.count
            player = nil
            play(at: currentIndex, attempts: attempts + 1)
        }
    }

    private func playNext() {
        guard !playlist.isEmpty else {
            player = nil
            return
        }

        currentIndex = (currentIndex + 1) % playlist.count
        play(at: currentIndex, attempts: 0)
    }

    private func applyMusicSetting() {
        if isMusicEnabled {
            startIfNeeded()
        } else {
            stop()
        }
    }

    private func stop() {
        player?.stop()
        player = nil
    }

    private var isMusicEnabled: Bool {
        UserDefaults.standard.object(forKey: AppSettingsService.musicEnabledKey)
            as? Bool ?? true
    }

    nonisolated private static func audioURL(for fileName: String) -> URL? {
        let cachedURL = RemoteContentService.cachedMusicURL(named: fileName)
        if FileManager.default.fileExists(atPath: cachedURL.path()) {
            return cachedURL
        }

        let nsName = fileName as NSString
        let ext = nsName.pathExtension
        let name = nsName.deletingPathExtension

        guard !name.isEmpty else {
            return nil
        }

        return Bundle.main.url(
            forResource: name,
            withExtension: ext.isEmpty ? nil : ext
        )
    }
}
