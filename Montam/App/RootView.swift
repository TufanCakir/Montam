//
//  RootView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct RootView: View {
    var onResetToStart: () -> Void = {}

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]
    @Query private var ownedSupporters: [OwnedSupporterData]
    @State private var selectedTab = RootTab.game
    @State private var didShowDailyLogin = false
    @State private var presentedModal: RootModal?
    @State private var navigationPreloadTask: Task<Void, Never>?

    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

    private var gameStore: GameStore {
        GameStore(
            modelContext: modelContext,
            saves: saves,
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            ownedSupporters: ownedSupporters
        )
    }

    private var isModalPresented: Bool {
        presentedModal != nil
    }

    var body: some View {
        ZStack {
            layeredRootContent

            VStack(spacing: 0) {
                RootGameHeader(
                    status: gameStore.playerStatusState(
                        monsters: monsterCatalog
                    )
                )
                .frame(height: RootLayoutMetrics.headerHeight)
                .ignoresSafeArea(.container, edges: .top)

                Spacer(minLength: 0)

                RootGameFooter(selectedTab: $selectedTab)
                    .frame(height: RootLayoutMetrics.footerHeight)
                    .ignoresSafeArea(.container, edges: .bottom)
            }

            if selectedTab == .game && !isModalPresented {
                RootQuickMenuButton {
                    presentModal(.quickMenu)
                }
                .transition(.scale.combined(with: .opacity))
            }

            if isModalPresented {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeModals()
                    }
            }

            if let presentedModal {
                modalContent(for: presentedModal)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            RootSaveMigrationService.migrateLegacyMonsterIds(
                ownedMonsters: ownedMonsters,
                modelContext: modelContext
            )
            presentDailyIfNeeded()
            preloadContentForNavigation()
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .game {
                presentDailyIfNeeded()
            }
            preloadContentForNavigation()
        }
        .onDisappear {
            navigationPreloadTask?.cancel()
            navigationPreloadTask = nil
        }
    }

    private func closeModals() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            presentedModal = nil
        }
    }

    private func presentModal(_ modal: RootModal) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            presentedModal = modal
        }
    }

    private func preloadContentForNavigation() {
        let preloadPlan = preloadPlan(for: selectedTab)
        navigationPreloadTask?.cancel()
        navigationPreloadTask = Task {
            await RemoteContentService.shared.preloadForNavigation(
                jsonFiles: preloadPlan.jsonFiles,
                additionalAssetKeys: preloadPlan.additionalAssetKeys,
                includeConfiguredAssetFiles:
                    preloadPlan.includeConfiguredAssetFiles,
                includeMusic: preloadPlan.includeMusic,
                showOverlay: true
            )
        }
    }

    private func preloadPlan(for tab: RootTab) -> RootContentPreloadPlan {
        switch tab {
        case .game:
            RootContentPreloadPlan(
                jsonFiles: [
                    "background",
                    "battleConfig",
                    "enemy",
                    "gameVisual",
                    "monster",
                    "music",
                    "tamer",
                ],
                additionalAssetKeys: ["enemyName"],
                includeMusic: true
            )
        case .tamer:
            RootContentPreloadPlan(
                jsonFiles: ["gameVisual", "monster"]
            )
        case .montam:
            RootContentPreloadPlan(
                jsonFiles: [
                    "evolution",
                    "monster",
                    "monsterAppearance",
                    "summon",
                    "supportMegaMonster",
                    "supportMonster",
                    "supportTamer",
                    "tamer",
                ],
                additionalAssetKeys: ["enemyName"]
            )
        case .dungeon:
            RootContentPreloadPlan(
                jsonFiles: [
                    "background",
                    "battleConfig",
                    "enemy",
                    "event",
                    "gameVisual",
                    "monster",
                    "tamer",
                ],
                additionalAssetKeys: ["enemyName"]
            )
        case .summon:
            RootContentPreloadPlan(
                jsonFiles: [
                    "gameVisual",
                    "monster",
                    "monsterAppearance",
                    "summon",
                    "summonCategory",
                    "summonPool",
                    "supportMegaMonster",
                    "supportMonster",
                    "supportTamer",
                    "tamer",
                ]
            )
        case .shop:
            RootContentPreloadPlan(
                jsonFiles: ["gameVisual", "itemShop", "shop"]
            )
        case .trade:
            RootContentPreloadPlan(
                jsonFiles: ["gameVisual", "trade"]
            )
        }
    }

    private func presentDailyIfNeeded() {
        guard selectedTab == .game,
            !didShowDailyLogin,
            DailyLoginService.availableReward(saves: saves) != nil
        else {
            return
        }

        didShowDailyLogin = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                presentedModal = .daily
            }
        }
    }

    @ViewBuilder
    private func modalContent(for modal: RootModal) -> some View {
        switch modal {
        case .quickMenu:
            RootQuickMenuPanel(
                onPassTap: { presentModal(.pass) },
                onDailyTap: { presentModal(.daily) },
                onGiftTap: { presentModal(.gift) },
                onNewsTap: { presentModal(.news) },
                onMissionTap: { presentModal(.mission) },
                onLegalTap: { presentModal(.legal) },
                onSettingsTap: { presentModal(.settings) },
                onClose: closeModals
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        case .settings:
            AppSettingsPanel(
                onClose: closeModals,
                onDataDeleted: {
                    closeModals()
                    onResetToStart()
                },
                onCacheCleared: {
                    closeModals()
                    onResetToStart()
                }
            )
            .transition(.scale.combined(with: .opacity))
        case .legal:
            AppLegalPanel(onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        case .news:
            NewsPanel(onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        case .mission:
            MissionPanel(onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        case .pass:
            BattlePassPanel(store: gameStore, onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        case .daily:
            DailyLoginPanel(onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        case .gift:
            GiftBoxPanel(onClose: closeModals)
                .transition(.scale.combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var layeredRootContent: some View {
        ZStack {
            GameView(store: gameStore)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(selectedTab == .game)

            if selectedTab != .game {
                AppScreenBackground()
                    .ignoresSafeArea()

                rootContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, RootLayoutMetrics.headerHeight)
                    .padding(.bottom, RootLayoutMetrics.footerHeight)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var rootContent: some View {
        switch selectedTab {
        case .tamer:
            MonsterSelectView(store: gameStore)
        case .montam:
            TeamView(store: gameStore)
        case .dungeon:
            EventView()
        case .game:
            EmptyView()
        case .summon:
            SummonView(store: gameStore)
        case .shop:
            ShopView(gameStore: gameStore)
        case .trade:
            TradeView()
        }
    }
}

private enum RootModal {
    case daily
    case gift
    case news
    case mission
    case pass
    case settings
    case quickMenu
    case legal
}

private struct RootContentPreloadPlan {
    let jsonFiles: [String]
    let additionalAssetKeys: Set<String>
    let includeConfiguredAssetFiles: Bool
    let includeMusic: Bool

    init(
        jsonFiles: [String],
        additionalAssetKeys: Set<String> = [],
        includeConfiguredAssetFiles: Bool = false,
        includeMusic: Bool = false
    ) {
        self.jsonFiles = jsonFiles
        self.additionalAssetKeys = additionalAssetKeys
        self.includeConfiguredAssetFiles = includeConfiguredAssetFiles
        self.includeMusic = includeMusic
    }
}

#Preview {
    RootView()
}
