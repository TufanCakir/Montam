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
    @State private var selectedTab = RootTab.game
    @State private var didShowDailyLogin = false
    @State private var isDailyPresented = false
    @State private var isGiftPresented = false
    @State private var isSettingsPresented = false
    @State private var isNewsPresented = false

    private var isModalPresented: Bool {
        isDailyPresented || isGiftPresented || isSettingsPresented || isNewsPresented
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RootGameHeader()
                    .frame(height: 94)
                    .ignoresSafeArea(.container, edges: .top)

                rootContent

                RootGameFooter(selectedTab: $selectedTab)
                    .frame(height: 98)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .blur(radius: isModalPresented ? 8 : 0)

            RootTopActionButtons(
                onDailyTap: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        isDailyPresented = true
                    }
                },
                onGiftTap: {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        isGiftPresented = true
                    }
                },
                onNewsTap: {
                    withAnimation(
                        .spring(response: 0.28, dampingFraction: 0.86)
                    ) {
                        isNewsPresented = true
                    }
                },
                onSettingsTap: {
                    withAnimation(
                        .spring(response: 0.28, dampingFraction: 0.86)
                    ) {
                        isSettingsPresented = true
                    }
                }
            )
            .opacity(isModalPresented ? 0 : 1)

            if isModalPresented {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeModals()
                    }
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

            if isDailyPresented {
                DailyLoginPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }

            if isGiftPresented {
                GiftBoxPanel(onClose: closeModals)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(rootBackground)
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
    private var rootContent: some View {
        switch selectedTab {
        case .tamer:
            MonsterSelectView()
        case .montam:
            TeamView()
        case .dungeon:
            EventView()
        case .game:
            GameView()
        case .summon:
            SummonView()
        case .shop:
            ShopView()
        case .trade:
            TradeView()
        }
    }

    @ViewBuilder
    private var rootBackground: some View {
        Color.clear
    }
}

#Preview {
    RootView()
}
