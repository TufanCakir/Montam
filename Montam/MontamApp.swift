//
//  MontamApp.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI
import AVFAudio

@main
struct MontamApp: App {

        @StateObject private var network = NetworkMonitor.shared

        @StateObject private var appModel = AppModel()
        @StateObject private var eventManager = EventManager.shared

        @Environment(\.scenePhase)
        private var scenePhase

        init() {
            configureApp()
            MusicManager.shared.play()
        }

        var body: some Scene {

            WindowGroup {
                Group {
                    if network.isConnected {

                        ZStack {

                            switch appModel.appState {
                            case .remoteLoading:
                                RemoteLoadingView()
                            case .maintenance:
                                MaintenanceView()
                            case .start:
                                StartView()
                            case .tutorial:
                                TutorialView()
                            case .starterSelection:
                                StarterSelectionView()
                            case .home:
                                RootView()
                            case .game:
                                GameView()
                            }

                            if appModel.isTransitionLoading {
                                TransitionLoadingView()
                                    .zIndex(999)
                            }
                        }
                        .animation(
                            .easeInOut(duration: 0.5),
                            value: appModel.appState
                        )

                    } else {
                        OfflineView()
                    }
                }
                .environmentObject(appModel)
                .environmentObject(MontamCoinsManager.shared)
                .environmentObject(MontamSaphirsManager.shared)
                .environmentObject(MontamLiquidManager.shared)
                .environmentObject(MontamShardsManager.shared)
                .environmentObject(EggInventoryManager.shared)
                .environmentObject(PlayerProgressManager.shared)
                .environmentObject(eventManager)
                .preferredColorScheme(.dark)
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {

                case .active:
                    EventManager.shared.load()
                    MusicManager.shared.resume()

                case .inactive:
                    MusicManager.shared.pause()

                case .background:
                    saveGameState()
                    MusicManager.shared.pause()

                @unknown default:
                    break
                }
            }
            .onChange(of: appModel.appState) { _, state in
                switch state {
                case .game, .home:
                    MusicManager.shared.play()
                case .remoteLoading, .maintenance, .start, .tutorial,
                    .starterSelection:
                    MusicManager.shared.stop()
                }
            }
        }
    }

    extension MontamApp {

        fileprivate func configureApp() { 
            print("Montam Booting...")

            // 🎵 Audio Session
            try? AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default
            )
            try? AVAudioSession.sharedInstance().setActive(true)

            // 🎵 Manager initialisieren
            _ = MusicManager.shared
        }

        fileprivate func saveGameState() {

            UserDefaults.standard.set(
                Date().timeIntervalSince1970,
                forKey: "montam_idle_last_seen"
            )
            print("Saving game state...")
        }
    }
