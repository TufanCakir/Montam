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
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
            }
        }
        .background(AppScreenBackground())
        .fullScreenCover(item: $selectedEvent) { event in
            EventBattleView(event: event) {
                selectedEvent = nil
            }
        }
        .padding(.top, 18)
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

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(
                        .system(size: 8, weight: .heavy, design: .rounded)
                    )
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.leading, 14)

            if let rewardOverlay {
                EventRewardOverlay(data: rewardOverlay)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            configureScene()
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
                title: event.title,
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
        HStack(spacing: 6) {
            rewardBadge

            ZStack(alignment: .trailing) {
                LinearGradient(
                    colors: [
                        item.accent.opacity(0.65), .blue.opacity(0.62),
                        .black.opacity(0.5),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .overlay(EventCardPattern().opacity(0.17))

                RemoteAssetImage(imageName: item.enemyAsset)
                    .scaledToFit()
                    .frame(width: item.category == "boss" ? 94 : 76)
                    .offset(x: item.category == "boss" ? 16 : 12)
                    .opacity(0.92)

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(
                            .system(
                                size: item.title.contains("\n") ? 18 : 21,
                                weight: .heavy,
                                design: .rounded
                            )
                        )
                        .italic()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.50)
                        .shadow(color: .black.opacity(0.55), radius: 1, y: 1)

                    Text(item.subtitle)
                        .font(
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .italic()
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.50)

                    Spacer()

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.dateText)
                            .font(
                                .system(
                                    size: 9,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .shadow(color: .black, radius: 1)

                        HStack(spacing: 6) {
                            EventLimitPill(text: item.playLimitText)
                            EventRewardPills(rewards: item.rewards)

                            if let adProgress = item.adProgress {
                                EventCounter(
                                    iconId: "summon_ticket",
                                    text: adProgress
                                )
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.leading, 14)
                .padding(.trailing, 74)
                .frame(maxWidth: .infinity, alignment: .leading)

                if item.locked {
                    Color.black.opacity(0.55)
                    Text("Bald verfügbar")
                        .font(
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            .clipShape(EventSlantedCardShape())
            .overlay(
                EventSlantedCardShape().stroke(
                    .cyan.opacity(0.45),
                    lineWidth: 1.5
                )
            )
        }
        .frame(height: item.category == "boss" ? 108 : 98)
    }

    private var rewardBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.cyan.opacity(0.45), lineWidth: 1)
                )

            VStack(spacing: 7) {
                ForEach(item.rewards.prefix(3)) { reward in
                    GameResourceIcon(id: reward.currency, fallbackImage: nil)
                        .frame(width: 23, height: 23)
                }
            }
        }
        .frame(width: 42)
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
            Text("Belohnung")
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

private struct EventLimitPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(
                .system(size: 10, weight: .heavy, design: .rounded)
            )
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.50)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color.black.opacity(0.24))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct EventRewardPills: View {
    let rewards: [EventRewardItem]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(rewards.prefix(3)) { reward in
                HStack(spacing: 4) {
                    GameResourceIcon(id: reward.currency, fallbackImage: nil)
                        .frame(width: 15, height: 15)
                    Text(GameNumberFormatter.compact(reward.amount))
                        .font(
                            .system(size: 10, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 5)
                .frame(height: 24)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }
}

private struct EventCardPattern: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<28, id: \.self) { index in
                Rectangle()
                    .fill(
                        index.isMultiple(of: 2)
                            ? .white.opacity(0.35) : .black.opacity(0.24)
                    )
                    .frame(width: 9, height: 130)
                    .rotationEffect(.degrees(18))
            }
        }
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
    let subtitle: String
    let rewards: [EventRewardItem]
    let dateText: String
    let playLimitText: String
    let enemyAsset: String
    let accent: Color
    let progress: String
    let adProgress: String?
    let timer: String?
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
                title: event.title,
                subtitle: event.description,
                rewards: event.rewards,
                dateText: dateText(for: event),
                playLimitText: playLimitText(for: event),
                enemyAsset: enemy?.enemyName ?? event.enemyName,
                accent: accent(for: event.category),
                progress: event.progress ?? "0/\(event.maxPlays ?? 0)",
                adProgress: event.adProgress,
                timer: event.timer,
                locked: event.locked ?? false
            )
        }
    }

    private static func playLimitText(for event: EventData) -> String {
        if let maxPlays = event.maxPlays {
            return "\(event.progress ?? "0/\(maxPlays)") Versuche"
        }

        return "Mehrfach"
    }

    private static func dateText(for event: EventData) -> String {
        if let startDate = event.startDate, let endDate = event.endDate {
            return
                "\(formatGermanDate(startDate)) - \(formatGermanDate(endDate))"
        }

        return "\(event.durationDays) Tage"
    }

    private static func formatGermanDate(_ value: String) -> String {
        guard let date = inputDateFormatter.date(from: value) else {
            return value
        }

        return outputDateFormatter.string(from: date)
    }

    private static func accent(for category: String) -> Color {
        switch category {
        case "boss": .red
        case "hunt": .pink
        case "daily": .cyan
        default: .blue
        }
    }

    private static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
}

#Preview {
    EventView()
}
