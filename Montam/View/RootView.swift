//
//  RootView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct RootView: View {

    enum Tab: String, Hashable {
        case home
        case team
        case summon
        case shop
        case exchange
        case upgrade
    }

    enum HomeRoute: Hashable {
        case menu
        case story
        case hatchery
        case wardrobe
        case events
        case gifts
        case passes
        case news
        case settings
    }

    @EnvironmentObject var appModel: AppModel
    @ObservedObject private var dailyRewardManager = DailyRewardManager.shared
    @State private var homeRoute: HomeRoute = .menu
    @State private var showsDailyLogin = false
    @State private var didPresentDailyLoginThisSession = false

    var body: some View {

        GameLayout(selectedTab: selectedTabBinding) {
            currentView
        }
        .onAppear {
            refreshDailyLogin()
        }
        .sheet(isPresented: $showsDailyLogin) {
            DailyLoginPopupView()
        }
        .onChange(of: appModel.selectedTab) { _, tab in
            if tab == .home {
                homeRoute = .menu
            }
            refreshDailyLogin()
        }
        .onChange(of: appModel.appState) { _, _ in
            refreshDailyLogin()
        }
    }

    private var selectedTabBinding: Binding<Tab> {
        Binding(
            get: {
                appModel.selectedTab
            },
            set: { tab in
                appModel.navigateWithLoading {
                    appModel.selectedTab = tab
                    if tab == .home {
                        homeRoute = .menu
                    }
                }
            }
        )
    }

    private func refreshDailyLogin() {
        guard appModel.appState == .home else { return }
        guard !didPresentDailyLoginThisSession else { return }
        dailyRewardManager.refreshAvailability()
        if dailyRewardManager.canClaimToday {
            showsDailyLogin = true
            didPresentDailyLoginThisSession = true
        }
    }
}

extension RootView {

    @ViewBuilder
    var currentView: some View {

        switch appModel.selectedTab {

        case .home:
            homeContent

        case .team:
            TeamView(teamManager: appModel.teamManager)

        case .summon:
            SummonView(teamManager: appModel.teamManager)

        case .shop:
            ShopView()

        case .exchange:
            ExchangeView()

        case .upgrade:
            UpgradeView(teamManager: appModel.teamManager)
        }
    }

    @ViewBuilder
    private var homeContent: some View {
        switch homeRoute {
        case .menu:
            MenuView { route in
                appModel.navigateWithLoading {
                    homeRoute = route
                }
            }

        case .story:
            routedView { StorySelectionView() }

        case .hatchery:
            routedView { HatcheryView() }

        case .wardrobe:
            routedView { WardrobeView(teamManager: appModel.teamManager) }

        case .events:
            routedView { EventView() }

        case .gifts:
            routedView { GiftView() }

        case .passes:
            routedView { PassView() }

        case .news:
            routedView { NewsView() }

        case .settings:
            routedView { SettingsView() }
        }
    }

    private func routedView<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    appModel.navigateWithLoading {
                        homeRoute = .menu
                    }
                } label: {
                    Text("ZURUECK")
                        .font(
                            .system(size: 11, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.black)
                        .padding(.horizontal, 16)
                        .frame(height: 34)
                        .background(MontamPalette.gold)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 8)

            content()
        }
    }
}
