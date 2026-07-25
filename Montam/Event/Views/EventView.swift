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
            selectedMonsters:
                ownedMonsters
                .filter(\.isSelected)
                .map {
                    RuntimeOwnedMonster(
                        monsterId: $0.monsterId,
                        level: $0.level,
                        xp: $0.xp,
                        imageName: $0.equippedImageName
                    )
                },
            selectedTamers:
                ownedTamers
                .filter(\.isSelected)
                .map {
                    RuntimeOwnedTamer(
                        tamerId: $0.tamerId,
                        level: $0.level,
                        xp: $0.xp
                    )
                }
        )
        scene.onBossBattleWon = {
            applyRewards()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                onClose()
            }
        }
    }

    private func applyRewards() {
        EventRewardService.applyRewards(
            from: event,
            saves: saves,
            modelContext: modelContext
        )
    }
}

private struct DungeonEventCard: View {
    let item: DungeonEventItem

    var body: some View {
        HStack(spacing: 0) {
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

                Image(item.enemyAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: item.category == "boss" ? 230 : 150)
                    .offset(x: item.category == "boss" ? 32 : 10)
                    .shadow(color: item.accent.opacity(0.75), radius: 7)

                VStack(alignment: .leading, spacing: 7) {
                    Text(item.title)
                        .font(
                            .system(
                                size: item.title.contains("\n") ? 23 : 27,
                                weight: .heavy,
                                design: .rounded
                            )
                        )
                        .italic()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 2, x: 2, y: 2)

                    Text(item.subtitle)
                        .font(
                            .system(size: 17, weight: .heavy, design: .rounded)
                        )
                        .italic()
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.dateText)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .shadow(color: .black, radius: 1)

                        HStack(spacing: 8) {
                            EventLimitPill(text: item.playLimitText)
                            EventRewardPills(rewards: item.rewards)

                            if let adProgress = item.adProgress {
                                EventCounter(
                                    iconId: "summon_ticket",
                                    text: adProgress,
                                    color: .white
                                )
                            }
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
                        .font(
                            .system(size: 24, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                }
            }
            .clipShape(EventSlantedCardShape())
            .overlay(
                EventSlantedCardShape().stroke(
                    .blue.opacity(0.95),
                    lineWidth: 3
                )
            )
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

            VStack(spacing: -8) {
                ForEach(item.rewards.prefix(3)) { reward in
                    GameResourceIcon(id: reward.currency, fallbackImage: nil)
                        .frame(width: 34, height: 34)
                        .shadow(color: .white.opacity(0.75), radius: 1)
                        .rotationEffect(.degrees(-12))
                }
            }
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
        .overlay(
            RoundedRectangle(cornerRadius: 4).stroke(
                .cyan.opacity(0.5),
                lineWidth: 1
            )
        )
    }
}

private struct EventLimitPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .padding(.horizontal, 8)
            .frame(height: 28)
            .background(.black.opacity(0.28))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(
                    .cyan.opacity(0.4),
                    lineWidth: 1
                )
            )
    }
}

private struct EventRewardPills: View {
    let rewards: [EventRewardItem]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(rewards.prefix(3)) { reward in
                HStack(spacing: 4) {
                    GameResourceIcon(id: reward.currency, fallbackImage: nil)
                        .frame(width: 20, height: 20)
                    Text(GameNumberFormatter.compact(reward.amount))
                        .font(
                            .system(size: 13, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                }
                .frame(height: 28)
                .background(.blue.opacity(0.68))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(
                        .cyan.opacity(0.5),
                        lineWidth: 1
                    )
                )
            }
        }
        .padding()
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
        let input = DateFormatter()
        input.locale = Locale(identifier: "de_DE")
        input.dateFormat = "yyyy-MM-dd"

        guard let date = input.date(from: value) else {
            return value
        }

        let output = DateFormatter()
        output.locale = Locale(identifier: "de_DE")
        output.dateFormat = "dd.MM.yyyy"
        return output.string(from: date)
    }

    private static func accent(for category: String) -> Color {
        switch category {
        case "boss": .red
        case "hunt": .pink
        case "daily": .cyan
        default: .blue
        }
    }

    private static func loadJSON<T: Decodable>(
        _ fileName: String,
        as type: T.Type
    ) -> T? {
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
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
