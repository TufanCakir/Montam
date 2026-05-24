//
//  AppModel.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Combine
import SwiftUI

final class AppModel: ObservableObject {

    // MARK: - Persistent Keys
    private let tutorialFightKey = "tutorial_fight_done"
    private let tutorialSummonKey = "tutorial_summon_done"
    private let firstTutorialKey = "drakon_first_tutorial_done"
    let tutorialLevelId = "tutorial_level"

    @Published var tutorialState: TutorialState = .none

    enum TutorialState {
        case none
        case fight
        case summon
        case done
    }

    // MARK: - Managers

    let teamManager = TeamManager()
    let coinManager = CoinManager.shared
    let crystalManager = GemManager.shared

    // MARK: - Persistent Keys
    private let homeModeKey = "homeMode"
    private let starterKey = "drakon_starter_given"

    // MARK: - Published State

    @Published var appState: AppState = .remoteLoading

    @Published var selectedTab: RootView.Tab = .home

    @Published var selectedLevelId: String?
    @Published var selectedStoryChapter: StoryChapter?
    @Published var selectedBattleDifficulty: BattleDifficulty?
    // MARK: - Loading Overlay
    @Published var isTransitionLoading: Bool = false
    @Published var currentLoadingImage: String = "loading1"
    @Published var loadingTitle: String = "REMOTE SYNC"
    @Published var loadingSubtitle: String = "Lade Drakon Daten"
    @Published var homeMode: HomeMode = .island {
        didSet {
            UserDefaults.standard.set(homeMode.rawValue, forKey: homeModeKey)
        }
    }

    func pickLoadingImage() {
        currentLoadingImage = loadingImages.randomElement() ?? "drakon_icon"
    }

    /// Zufälliges Loading Bild
    let loadingImages = [
        "drakon_icon",
        "skin_pyro_baby_default",
        "skin_blazion_rookie_default",
        "skin_infernon_advanced_default",
        "skin_solarion_defaul",
    ]

    enum AppState {
        case remoteLoading
        case maintenance
        case start
        case tutorial
        case starterSelection
        case home  // ✅ NEU
        case game
    }

    // MARK: - Init
    init() {
        determineTutorialState()  // 👈 ZUERST!
        initializeGameIfNeeded()
    }

    private func determineTutorialState() {
        let d = UserDefaults.standard

        let fightDone = d.bool(forKey: tutorialFightKey)
        let summonDone = d.bool(forKey: tutorialSummonKey)

        if !fightDone {
            tutorialState = .fight
        } else if !summonDone {
            tutorialState = .summon
        } else {
            tutorialState = .done
        }
    }

    // MARK: - Game Boot

    /// Called on first app launch or after full reset
    func initializeGameIfNeeded() {
        loadHomeMode()
    }

    func loadHomeMode() {
        if let saved = UserDefaults.standard.string(forKey: homeModeKey),
            let mode = HomeMode(rawValue: saved)
        {
            homeMode = mode
        }
    }

    // MARK: - Navigation mit Loading

    func switchToGame() {
        pickLoadingImage()
        isTransitionLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.appState = .game

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.isTransitionLoading = false
            }
        }
    }

    func navigateWithLoading(_ action: @escaping () -> Void) {
        pickLoadingImage()
        loadingTitle = "REMOTE SYNC"
        loadingSubtitle = "Pruefe Live-Service Daten"
        isTransitionLoading = true

        RemoteDownloadManager.shared.preloadForNavigation(
            files: remoteBootFiles
        ) {
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.isTransitionLoading = false
            }
        }
    }

    /// Called when player presses "Start"
    func startGame() {
        selectedTab = .home
        guard hasCompletedFirstTutorial else {
            appState = .tutorial
            return
        }
        appState = hasChosenStarter ? .home : .starterSelection
    }

    var hasCompletedFirstTutorial: Bool {
        UserDefaults.standard.bool(forKey: firstTutorialKey)
    }

    func completeFirstTutorial() {
        UserDefaults.standard.set(true, forKey: firstTutorialKey)
        selectedTab = .home
        appState = hasChosenStarter ? .home : .starterSelection
    }

    func startBattle() {
        selectedStoryChapter = nil
        selectedBattleDifficulty = nil
        appState = hasChosenStarter ? .game : .starterSelection
    }

    func startStoryBattle(
        chapter: StoryChapter,
        difficulty: BattleDifficulty
    ) {
        EventRuntime.shared.clear()
        selectedStoryChapter = chapter
        selectedBattleDifficulty = difficulty
        selectedLevelId = chapter.id
        appState = hasChosenStarter ? .game : .starterSelection
    }

    func startEventBattle(
        event: GameEvent,
        difficulty: BattleDifficulty
    ) {
        selectedStoryChapter = nil
        selectedBattleDifficulty = difficulty
        EventRuntime.shared.activate(event)
        selectedLevelId = event.bossLevelId ?? event.id
        appState = hasChosenStarter ? .game : .starterSelection
    }

    func resetTutorial() {
        let d = UserDefaults.standard
        d.removeObject(forKey: tutorialFightKey)
        d.removeObject(forKey: tutorialSummonKey)
        tutorialState = .none
    }

    var hasChosenStarter: Bool {
        guard
            GameConfigManager.shared.config.starterSelection
                .requiredForNewAccount
        else {
            return true
        }

        let keyWasSet = UserDefaults.standard.bool(forKey: starterKey)
        let accountHasDrakonStarter = teamManager.ownedCharacters.contains {
            $0.baseId.hasPrefix("character_drakon_")
        }

        if keyWasSet && !accountHasDrakonStarter {
            UserDefaults.standard.removeObject(forKey: starterKey)
            return false
        }

        return keyWasSet && accountHasDrakonStarter
    }

    private var remoteBootFiles: [String] {
        [
            "game_config",
            "starter_eggs",
            "characters",
            "summons",
            "shop",
            "events",
            "event_attacks",
            "gifts",
            "pass_index",
            "pass_rewards",
            "launchpass",
            "starterpass",
            "babypass",
            "rookiepass",
            "advancedpass",
            "imperialpass",
            "daily_rewards",
            "service_status",
            "news",
            "upgrade_config",
            "eggs",
            "skins",
            "tutorials",
        ]
    }

    func chooseStarter(characterId: String) {
        chooseStarters(characterIds: [characterId])
    }

    func chooseStarters(characterIds: [String]) {
        guard !hasChosenStarter else { return }

        do {
            let characters: [Character] = try JSONLoader.load("characters")

            for characterId in characterIds {
                guard
                    let starter = characters.first(where: {
                        $0.id == characterId
                    })
                else {
                    print("Starter not found:", characterId)
                    continue
                }

                let owned = OwnedCharacter(base: starter)
                teamManager.addOwnedCharacter(owned)
            }

            teamManager.activeTeam = Array(
                teamManager.ownedCharacters.prefix(teamManager.maxTeamSize)
            )
            UserDefaults.standard.set(true, forKey: starterKey)

            selectedTab = .home
            appState = .home
        } catch {
            print("Starter load failed:", error)
        }
    }

    // MARK: - Reset
    func fullReset() {
        AccountResetManager.resetAll()

        // ⭐ RESET USERDEFAULTS (WICHTIG)
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: tutorialFightKey)
        defaults.removeObject(forKey: tutorialSummonKey)
        defaults.removeObject(forKey: starterKey)
        defaults.removeObject(forKey: firstTutorialKey)

        // ⭐ RESET SINGLETONS
        CoinManager.shared.reset()
        GemManager.shared.reset()
        DailyRewardManager.shared.reset()
        GiftClaimManager.shared.reset()
        ExchangeManager.shared.reset()
        PlayerProgressManager.shared.reset()
        PityManager.shared.resetAll()
        RubyManager.shared.reset()
        ShardManager.shared.reset()
        EventCurrencyManager.shared.reset()
        DrakenManager.shared.reset()
        EggInventoryManager.shared.reset()
        SkinInventoryManager.shared.reset()
        PassProgressManager.shared.reset()
        DrakonMedalManager.shared.reset()

        // ⭐ RESET LOCAL STATE
        teamManager.reset()
        selectedLevelId = nil

        tutorialState = .none

        // ⭐ RELOAD
        determineTutorialState()
        initializeGameIfNeeded()

        appState = .start
    }

}
