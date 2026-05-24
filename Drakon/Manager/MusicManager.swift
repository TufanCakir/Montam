//
//  MusicManager.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import AVFoundation
import Combine
import Foundation

final class MusicManager: NSObject, ObservableObject {

    // MARK: - Singleton
    static let shared = MusicManager()

    // MARK: - Published State
    @Published var isMuted: Bool = false
    @Published var volume: Float = 1.0

    // MARK: - Keys
    private let volumeKey = "music_volume"
    private let muteKey = "music_muted"

    // MARK: - Models
    struct MusicConfig: Codable {
        let tracks: [Track]
        let loop: Bool
        let shuffle: Bool
    }

    struct Track: Codable {
        let id: String?
        let file: String
        let volume: Double?  // optional per-track volume
    }

    // MARK: - Player
    private var player: AVAudioPlayer?
    private var playlist: [Track] = []
    private var currentIndex: Int = 0
    private var shouldLoop = true
    private var shouldShuffle = false
    private var isPlaying = false

    // MARK: - Init
    private override init() {
        super.init()

        configureAudioSession()
        loadSavedSettings()
        loadMusicConfig()
    }

    // MARK: - Setup
    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func loadSavedSettings() {
        isMuted = UserDefaults.standard.bool(forKey: muteKey)

        let saved = UserDefaults.standard.float(forKey: volumeKey)
        volume = saved == 0 ? 1.0 : saved  // default = 100%
    }

    // MARK: - Controls
    func setVolume(_ value: Float) {
        volume = value
        updatePlayerVolume()
        UserDefaults.standard.set(value, forKey: volumeKey)
    }

    func toggleMute() {
        isMuted.toggle()
        updatePlayerVolume()
        UserDefaults.standard.set(isMuted, forKey: muteKey)
    }

    func play() {
        guard !playlist.isEmpty else { return }

        if player == nil {
            playTrack(at: currentIndex)
        } else {
            resume()
        }

        isPlaying = true
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func next() {
        advanceIndex()
        playTrack(at: currentIndex)
    }
}

// MARK: - Private Logic
extension MusicManager {

    fileprivate func loadMusicConfig() {
        guard let config: MusicConfig = try? JSONLoader.load("music") else {
            print("❌ music.json load failed")
            return
        }

        playlist = config.tracks
        shouldLoop = config.loop
        shouldShuffle = config.shuffle

        if shouldShuffle {
            playlist.shuffle()
        }

        print("🎵 Music loaded:", playlist.count, "tracks")
    }

    fileprivate func playTrack(at index: Int) {
        guard playlist.indices.contains(index) else { return }

        let track = playlist[index]
        let name = track.file.replacingOccurrences(of: ".mp3", with: "")
        let assetId = track.id ?? name

        guard let url = audioURL(for: track, assetId: assetId, name: name)
        else {
            print("❌ Missing file:", track.file)
            return
        }

        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()

            updatePlayerVolume()
            player?.play()

            print("▶️ Playing:", track.file)

        } catch {
            print("❌ Audio error:", error)
        }
    }

    fileprivate func audioURL(
        for track: Track,
        assetId: String,
        name: String
    ) -> URL? {
        if let remoteURL = RemoteAssetManager.shared.localURL(for: assetId) {
            return remoteURL
        }

        let fileExtension = URL(fileURLWithPath: track.file).pathExtension
        return Bundle.main.url(
            forResource: name,
            withExtension: fileExtension.isEmpty ? "mp3" : fileExtension
        )
    }

    fileprivate func updatePlayerVolume() {
        guard let player else { return }

        let trackVolume = Float(playlist[currentIndex].volume ?? 1.0)
        let finalVolume = isMuted ? 0 : volume * trackVolume

        player.volume = finalVolume
    }

    fileprivate func advanceIndex() {
        currentIndex += 1

        if currentIndex >= playlist.count {
            currentIndex = shouldLoop ? 0 : playlist.count - 1
        }
    }
}

// MARK: - Delegate
extension MusicManager: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        next()
    }
}
