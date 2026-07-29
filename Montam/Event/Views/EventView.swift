//
//  EventView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SpriteKit
import SwiftData
import SwiftUI

struct EventView: View {

    private let events = EventViewDataSource.loadEvents()
    @State private var selectedEvent: EventData?

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(events) { event in
                        Button {
                            selectedEvent = event.source
                        } label: {
                            DungeonEventCard(item: event)
                        }
                        .buttonStyle(.plain)
                        .disabled(event.locked)
                    }
                }
                .padding()
            }
        }
        .fullScreenCover(item: $selectedEvent) { event in
            EventBattleView(event: event) {
                selectedEvent = nil
            }
        }
        .padding(.top, 50)
    }
}

private struct EventBattleView: View {
    let event: EventData
    let onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]
    @Query private var ownedSupporters: [OwnedSupporterData]
    @State private var rewardOverlay: EventRewardOverlayData?

    private let monsterCatalog =
        JSONDataLoader.load("monster", as: [MonsterData].self) ?? []
    private let progression =
        JSONDataLoader.load("battleConfig", as: GameProgressionData.self)
        ?? GameProgressionData()

    private let scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        ZStack(alignment: .topLeading) {
            SpriteView(scene: scene)
                .ignoresSafeArea()

            if let rewardOverlay {
                EventRewardOverlay(data: rewardOverlay)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            configureScene()
        }
        .onDisappear {
            scene.isPaused = true
            scene.clearCallbacks()
        }
    }

    private func configureScene() {
        let store = GameStore(
            modelContext: modelContext,
            saves: saves,
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            ownedSupporters: ownedSupporters
        )

        scene.configureEvent(event)
        scene.configure(
            selectedMonsters: store.runtimeSelectedMonsters(),
            selectedTamers: store.runtimeSelectedTamers(),
            selectedSupporters: store.runtimeSelectedSupporters()
        )
        scene.onBattleWon = { reward in
            store.applyBattleReward(
                reward,
                monsterCatalog: monsterCatalog,
                progression: progression
            )
        }
        scene.onBossBattleWon = {
            applyRewards()
            rewardOverlay = EventRewardOverlayData(
                title: event.localizedTitle,
                rewards: event.rewards
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                onClose()
            }
        }
    }

    private func applyRewards() {
        EventRewardService.applyRewards(
            from: event,
            saves: saves,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }

}

private struct DungeonEventCard: View {
    let item: DungeonEventItem

    var body: some View {
        ZStack(alignment: .trailing) {
            RemoteAssetImage(imageName: item.backgroundAsset)
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            RemoteAssetImage(imageName: item.enemyAsset)
                .scaledToFit()
                .frame(width: item.category == "boss" ? 104 : 92)
                .padding(.trailing, 10)
        }
        .frame(height: item.category == "boss" ? 132 : 120)
        .clipShape(EventSlantedCardShape())
        .overlay(alignment: .leading) {
            cardContent
        }
        .overlay {
            if item.locked {
                ZStack {
                    Color.black.opacity(0.55)
                    Text(AppLocalizationService.text("shop.unavailable"))
                        .font(
                            .system(
                                size: 13,
                                weight: .heavy,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
                .clipShape(EventSlantedCardShape())
            }
        }
        .background(
            EventSlantedCardShape()
                .fill(Color.black.opacity(0.46))
                .offset(x: 10, y: 10)
        )
        .overlay(
            EventSlantedCardShape()
                .stroke(
                    item.accent.opacity(item.locked ? 0.28 : 0.72),
                    lineWidth: 2
                )
        )
        .shadow(color: .black.opacity(0.42), radius: 8, x: 8, y: 10)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(item.title)
                .font(
                    .system(
                        size: item.title.contains("\n") ? 20 : 24,
                        weight: .heavy,
                        design: .rounded
                    )
                )
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.58)
                .shadow(color: .black.opacity(0.75), radius: 2, y: 1)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                if let playLimitText = item.playLimitText {
                    Text(playLimitText)
                        .font(
                            .system(
                                size: 10,
                                weight: .heavy,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .background(Color.black.opacity(0.36))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                ForEach(item.rewards.prefix(3)) { reward in
                    HStack(spacing: 4) {
                        GameResourceIcon(
                            id: reward.currency,
                            fallbackImage: nil
                        )
                        .frame(width: 15, height: 15)

                        Text(GameNumberFormatter.compact(reward.amount))
                            .font(
                                .system(
                                    size: 10,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 5)
                    .frame(height: 24)
                    .background(Color.black.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                if let adProgress = item.adProgress {
                    EventCounter(
                        iconId: "summon_ticket",
                        text: adProgress
                    )
                }
            }
        }
        .padding(14)
        .padding(.trailing, 82)
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
    }
}

private struct EventCounter: View {
    let iconId: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            GameResourceIcon(id: iconId, fallbackImage: nil)
                .frame(width: 14, height: 14)
                .rotationEffect(.degrees(-10))

            Text(text)
                .font(
                    .system(size: 10, weight: .heavy, design: .rounded)
                )
                .foregroundStyle(.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct EventRewardOverlayData: Identifiable {
    let id = UUID()
    let title: String
    let rewards: [EventRewardItem]
}

private struct EventRewardOverlay: View {
    let data: EventRewardOverlayData

    var body: some View {
        VStack(spacing: 12) {
            Text(AppLocalizationService.text("event.reward"))
                .font(
                    .system(size: 8, weight: .heavy, design: .rounded)
                )
                .foregroundStyle(.white)

            Text(data.title)
                .font(
                    .system(size: 8, weight: .heavy, design: .rounded)
                )
                .foregroundStyle(.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(spacing: 10) {
                ForEach(data.rewards.prefix(4)) { reward in
                    VStack(spacing: 5) {
                        GameResourceIcon(
                            id: reward.currency,
                            fallbackImage: nil
                        )
                        .frame(width: 34, height: 34)
                        Text("+\(GameNumberFormatter.compact(reward.amount))")
                            .font(
                                .system(
                                    size: 8,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .frame(width: 62, height: 68)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: 330)
        .background(Color.black.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.cyan.opacity(0.55), lineWidth: 1.5)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.32).ignoresSafeArea())
    }
}

private struct EventSlantedCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 10, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX - 16, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.82))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - 38, y: rect.maxY),
                control: CGPoint(x: rect.maxX - 8, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: 14))
            path.addQuadCurve(
                to: CGPoint(x: 10, y: 0),
                control: CGPoint(x: 0, y: 2)
            )
            path.closeSubpath()
        }
    }
}

private struct DungeonEventItem: Identifiable {
    let id: String
    let source: EventData
    let category: String
    let title: String
    let rewards: [EventRewardItem]
    let playLimitText: String?
    let backgroundAsset: String
    let enemyAsset: String
    let accent: Color
    let adProgress: String?
    let locked: Bool
}

private enum EventViewDataSource {
    static func loadEvents() -> [DungeonEventItem] {
        let eventData =
            JSONDataLoader.load("event", as: [EventData].self) ?? []
        let enemies = JSONDataLoader.load("enemy", as: [EnemyData].self) ?? []

        return eventData.map { event in
            let enemy = enemies.first { $0.id == event.enemyName }
            return DungeonEventItem(
                id: event.id,
                source: event,
                category: event.category,
                title: event.localizedTitle,
                rewards: event.rewards,
                playLimitText: playLimitText(for: event),
                backgroundAsset: event.eventBackground,
                enemyAsset: enemy?.enemyName ?? event.enemyName,
                accent: accent(for: event.category),
                adProgress: event.adProgress,
                locked: event.locked ?? false
            )
        }
    }

    private static func playLimitText(for event: EventData) -> String? {
        if let maxPlays = event.maxPlays {
            return event.progress ?? "0/\(maxPlays)"
        }

        return nil
    }

    private static func accent(for category: String) -> Color {
        switch category {
        case "boss": .blue
        case "hunt": .blue
        case "daily": .blue
        default: .blue
        }
    }
}

#Preview {
    EventView()
}
