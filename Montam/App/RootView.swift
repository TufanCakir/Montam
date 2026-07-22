//
//  RootView.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct RootView: View {
    var onResetToStart: () -> Void = {}

    @Environment(\.modelContext) private var modelContext
    @Query private var ownedMonsters: [OwnedMonsterData]
    @State private var selectedTab = RootTab.game
    @State private var isSettingsPresented = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                RootGameHeader {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        isSettingsPresented = true
                    }
                }
                    .frame(height: 112)
                    .ignoresSafeArea(.container, edges: .top)

                rootContent

                RootGameFooter(selectedTab: $selectedTab)
                    .frame(height: 112)
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .blur(radius: isSettingsPresented ? 8 : 0)

            if isSettingsPresented {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSettingsPresented = false
                    }

                AppSettingsPanel(
                    onClose: {
                        isSettingsPresented = false
                    },
                    onDataDeleted: {
                        isSettingsPresented = false
                        onResetToStart()
                    }
                )
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
