//
//  AppModel.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import SwiftUI

final class AppModel: ObservableObject {

    // MARK: - Persistent Keys
    private let tutorialFightKey = "tutorial_fight_done"
    private let tutorialSummonKey = "tutorial_summon_done"
    private let firstTutorialKey = "montam_first_tutorial_done"
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
    let coinManager = MontamCoinsManager.shared
    let crystalManager = MontamSaphirsManager.shared

    private let starterKey = "montam_starter_given"

    // MARK: - Published State

    @Published var appState: AppState = .remoteLoading

    @Published var selectedTab: RootView.Tab = .home

    @Published var selectedLevelId: String?
    @Published var selectedStoryChapter: StoryChapter?
    @Published var selectedBattleDifficulty: BattleDifficulty?
    // MARK: - Loading Overlay
    @Published var currentLoadingImage: String = "loading1"
    @Published var loadingTitle: String = "REMOTE SYNC"
    @Published var loadingSubtitle: String = "Lade Montam Daten"

    func pickLoadingImage() {
        currentLoadingImage =
            availableLoadingImages.randomElement()
            ?? "montam_icon"
    }

    private var availableLoadingImages: [String] {
        let configured = GameConfigManager.shared.config.loadingImages ?? []
        if !configured.isEmpty {
            return configured
        }

        let manifest = JSONLoader.manifest()
        let imageExtensions: Set<String> = ["png", "jpg", "jpeg", "webp"]
        return manifest.assets
            .filter {
                imageExtensions.contains(
                    URL(fileURLWithPath: $0.file).pathExtension.lowercased()
                )
            }
            .map(\.id)
    }

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
    func initializeGameIfNeeded() {}

    // MARK: - Navigation mit Loading

    func switchToGame() {
        pickLoadingImage()
        appState = .game
    }

    func navigateWithLoading(_ action: @escaping () -> Void) {
        action()
    }

    /// Called when player presses "Start"
    func startGame() {
        selectedTab = .home
        guard hasChosenStarter else {
            appState = .starterSelection
            return
        }
        appState = hasCompletedFirstTutorial ? .home : .tutorial
    }

    var hasCompletedFirstTutorial: Bool {
        UserDefaults.standard.bool(forKey: firstTutorialKey)
    }

    func completeFirstTutorial() {
        UserDefaults.standard.set(true, forKey: firstTutorialKey)
        selectedTab = .home
        appState = .home
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
        let accountHasMontamStarter = teamManager.ownedCharacters.contains {
            $0.baseId.hasPrefix("character_montam_")
        }

        if keyWasSet && !accountHasMontamStarter {
            UserDefaults.standard.removeObject(forKey: starterKey)
            return false
        }

        return keyWasSet && accountHasMontamStarter
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
            appState = hasCompletedFirstTutorial ? .home : .tutorial
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
        MontamCoinsManager.shared.reset()
        MontamSaphirsManager.shared.reset()
        DailyRewardManager.shared.reset()
        GiftClaimManager.shared.reset()
        ExchangeManager.shared.reset()
        PlayerProgressManager.shared.reset()
        PityManager.shared.resetAll()
        MontamRubysManager.shared.reset()
        MontamShardsManager.shared.reset()
        MontamContainersManager.shared.reset()
        MontamLiquidManager.shared.reset()
        EggInventoryManager.shared.reset()
        SkinInventoryManager.shared.reset()
        PassProgressManager.shared.reset()
        MontamMedalManager.shared.reset()

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
