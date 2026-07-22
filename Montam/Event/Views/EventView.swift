//
//  EventView.swift
//  Monster Transorfmieren
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
            EventTitleBar()

            HStack(spacing: 8) {
                Text("Bis zum Zurücksetzen der Herausforderungsanzahl")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan.opacity(0.75))
                Image(systemName: "clock.fill")
                    .foregroundStyle(.yellow)
                Text("08:10:07")
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(.yellow)
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(Color(red: 0.0, green: 0.1, blue: 0.22))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
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
                .padding(.horizontal, 28)
                .padding(.top, 18)
                .padding(.bottom, 36)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            EventViewBackground()
        }
        .fullScreenCover(item: $selectedEvent) { event in
            EventBattleView(event: event) {
                selectedEvent = nil
            }
        }
    }
}

private struct EventBattleView: View {
    let event: EventData
    let onClose: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]

    private let rewards = JSONDataLoader.load("eventReward", as: [EventRewardData].self)?.first
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
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .padding(.top, 48)
            .padding(.leading, 14)
        }
        .onAppear {
            configureScene()
        }
    }

    private func configureScene() {
        scene.configureEvent(event)
        scene.configure(
            selectedMonsters: ownedMonsters
                .filter(\.isSelected)
                .map { RuntimeOwnedMonster(monsterId: $0.monsterId, level: $0.level, xp: $0.xp) },
            selectedTamers: ownedTamers
                .filter(\.isSelected)
                .map { RuntimeOwnedTamer(tamerId: $0.tamerId, level: $0.level, xp: $0.xp) }
        )
        scene.onBossBattleWon = {
            applyRewards()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                onClose()
            }
        }
    }

    private func applyRewards() {
        guard let save = saves.first else {
            return
        }

        save.coins += rewards?.eventCoins ?? 0
        save.crystals += rewards?.eventCrystals ?? 0
        try? modelContext.save()
    }
}

private struct EventTitleBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            Text("DUNGEON")
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundStyle(.blue.opacity(0.82))
            Image(systemName: "info.circle.fill")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.blue.opacity(0.75))
            Spacer()
        }
        .frame(height: 56)
        .background(
            LinearGradient(colors: [.cyan, .cyan.opacity(0.45), .cyan], startPoint: .leading, endPoint: .trailing)
        )
    }
}

private struct DungeonEventCard: View {
    let item: DungeonEventItem

    var body: some View {
        HStack(spacing: 0) {
            rewardBadge

            ZStack(alignment: .trailing) {
                LinearGradient(colors: [item.accent.opacity(0.65), .blue.opacity(0.62), .black.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                    .overlay(EventCardPattern().opacity(0.17))

                Image(item.enemyAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: item.category == "boss" ? 230 : 150)
                    .offset(x: item.category == "boss" ? 32 : 10)
                    .shadow(color: item.accent.opacity(0.75), radius: 7)

                VStack(alignment: .leading, spacing: 7) {
                    Text(item.title)
                        .font(.system(size: item.title.contains("\n") ? 23 : 27, weight: .heavy, design: .rounded))
                        .italic()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 2, x: 2, y: 2)

                    Text(item.subtitle)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .italic()
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)

                    Spacer()

                    HStack(spacing: 12) {
                        if let timer = item.timer {
                            Text(timer)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundStyle(.green)
                                .shadow(color: .black, radius: 1)
                        }

                        EventCounter(iconId: item.rewardCurrency, text: item.progress, color: item.accent)

                        if let adProgress = item.adProgress {
                            EventCounter(iconId: "summon_ticket", text: adProgress, color: .white)
                        }
                    }
                }
                .padding(.leading, 20)
                .padding(.vertical, 18)
                .padding(.trailing, 115)
                .frame(maxWidth: .infinity, alignment: .leading)

                if item.locked {
                    Color.black.opacity(0.55)
                    Text("Bald verfügbar")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            .clipShape(EventSlantedCardShape())
            .overlay(EventSlantedCardShape().stroke(.blue.opacity(0.95), lineWidth: 3))
        }
        .frame(height: item.category == "boss" ? 214 : 142)
        .shadow(color: .blue.opacity(0.55), radius: 0, x: 12, y: 12)
    }

    private var rewardBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.cyan.opacity(0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.cyan.opacity(0.95), lineWidth: 2)
                )

            GameResourceIcon(id: item.rewardCurrency, fallbackImage: nil)
                .frame(width: 46, height: 46)
                .shadow(color: .white.opacity(0.75), radius: 1)
                .rotationEffect(.degrees(-12))
        }
        .frame(width: 76)
        .padding(.vertical, 2)
    }
}

private struct EventCounter: View {
    let iconId: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            GameResourceIcon(id: iconId, fallbackImage: nil)
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-10))

            Text(text)
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(.blue.opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(.cyan.opacity(0.5), lineWidth: 1))
    }
}

private struct EventViewBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

private struct EventCardPattern: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<28, id: \.self) { index in
                Rectangle()
                    .fill(index.isMultiple(of: 2) ? .white.opacity(0.35) : .black.opacity(0.24))
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
            path.addQuadCurve(to: CGPoint(x: rect.maxX - 38, y: rect.maxY), control: CGPoint(x: rect.maxX - 8, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: 14))
            path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 0, y: 2))
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
    let rewardCurrency: String
    let enemyAsset: String
    let accent: Color
    let progress: String
    let adProgress: String?
    let timer: String?
    let locked: Bool
}

private enum EventViewDataSource {
    static func loadEvents() -> [DungeonEventItem] {
        let eventData = loadJSON("event", as: [EventData].self) ?? []
        let enemies = loadJSON("enemy", as: [EnemyData].self) ?? []

        return eventData.map { event in
            let enemy = enemies.first { $0.id == event.enemyName }
            return DungeonEventItem(
                id: event.id,
                source: event,
                category: event.category,
                title: event.title,
                subtitle: event.description,
                rewardCurrency: event.rewardCurrency,
                enemyAsset: enemy?.enemyName ?? event.enemyName,
                accent: accent(for: event.category),
                progress: event.progress ?? "0/0",
                adProgress: event.adProgress,
                timer: event.timer,
                locked: event.locked ?? false
            )
        }
    }

    private static func accent(for category: String) -> Color {
        switch category {
        case "boss": .red
        case "hunt": .pink
        case "daily": .cyan
        default: .blue
        }
    }

    private static func loadJSON<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}

#Preview {
    EventView()
}
