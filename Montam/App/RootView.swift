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
    @State private var selectedTab = RootTab.game
    @State private var didShowDailyLogin = false
    @State private var isDailyPresented = false
    @State private var isGiftPresented = false
    @State private var isSettingsPresented = false
    @State private var isNewsPresented = false
    @State private var isMissionPresented = false
    @State private var isQuickMenuPresented = false

    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []

    private var gameStore: GameStore {
        GameStore(
            modelContext: modelContext,
            saves: saves,
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers
        )
    }

    private var isModalPresented: Bool {
        isDailyPresented
            || isGiftPresented
            || isSettingsPresented
            || isNewsPresented
            || isMissionPresented
            || isQuickMenuPresented
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

            if isQuickMenuPresented {
                RootQuickMenuPanel(
                    onDailyTap: {
                        presentModal(.daily)
                    },
                    onGiftTap: {
                        presentModal(.gift)
                    },
                    onNewsTap: {
                        presentModal(.news)
                    },
                    onMissionTap: {
                        presentModal(.mission)
                    },
                    onSettingsTap: {
                        presentModal(.settings)
                    },
                    onClose: closeModals
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if isSettingsPresented {
                AppSettingsPanel(
                    onClose: {
                        closeModals()
                    },
                    onDataDeleted: {
                        closeModals()
                        onResetToStart()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }

            if isNewsPresented {
                NewsPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }

            if isMissionPresented {
                MissionPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }

            if isDailyPresented {
                DailyLoginPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }

            if isGiftPresented {
                GiftBoxPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            RootSaveMigrationService.migrateLegacyMonsterIds(
                ownedMonsters: ownedMonsters,
                modelContext: modelContext
            )
            presentDailyIfNeeded()
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .game {
                presentDailyIfNeeded()
            }
        }
    }

    private func closeModals() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            isDailyPresented = false
            isGiftPresented = false
            isSettingsPresented = false
            isNewsPresented = false
            isMissionPresented = false
            isQuickMenuPresented = false
        }
    }

    private func presentModal(_ modal: RootModal) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            isQuickMenuPresented = false

            switch modal {
            case .daily:
                isDailyPresented = true
            case .gift:
                isGiftPresented = true
            case .news:
                isNewsPresented = true
            case .mission:
                isMissionPresented = true
            case .settings:
                isSettingsPresented = true
            case .quickMenu:
                isQuickMenuPresented = true
            }
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
                isDailyPresented = true
            }
        }
    }

    @ViewBuilder
    private var layeredRootContent: some View {
        if selectedTab == .game {
            rootContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        } else {
            ZStack {
                AppScreenBackground()
                    .ignoresSafeArea()

                rootContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, RootLayoutMetrics.headerHeight)
                    .padding(.bottom, RootLayoutMetrics.footerHeight)
            }
            .ignoresSafeArea()
        }
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
            GameView(isPaused: isModalPresented, store: gameStore)
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
    case settings
    case quickMenu
}

#Preview {
    RootView()
}
