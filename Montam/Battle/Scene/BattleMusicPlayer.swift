//
//  BattleMusicPlayer.swift
//  Monster Transorfmieren
//

import AVFoundation
import Foundation

final class BattleMusicPlayer: NSObject, AVAudioPlayerDelegate {
    private var playlist: [URL] = []
    private var player: AVAudioPlayer?
    private var settingsObserver: NSObjectProtocol?
    private var currentIndex = 0

    override init() {
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
        playlist = fileNames.compactMap(Self.audioURL(for:))
        applyMusicSetting()
    }

    func startIfNeeded() {
        guard isMusicEnabled, player == nil, !playlist.isEmpty else {
            return
        }

        play(at: currentIndex)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard isMusicEnabled else {
            stop()
            return
        }

        currentIndex = (currentIndex + 1) % max(playlist.count, 1)
        play(at: currentIndex)
    }

    private func play(at index: Int) {
        guard isMusicEnabled, !playlist.isEmpty else {
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
        }
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
        UserDefaults.standard.object(forKey: AppSettingsService.musicEnabledKey) as? Bool ?? true
    }

    nonisolated private static func audioURL(for fileName: String) -> URL? {
        let nsName = fileName as NSString
        let ext = nsName.pathExtension
        let name = nsName.deletingPathExtension

        guard !name.isEmpty else {
            return nil
        }

        return Bundle.main.url(forResource: name, withExtension: ext.isEmpty ? nil : ext)
    }
}
