//
//  EventView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var eventManager: EventManager

    @State private var selectedCategoryId = "boss"
    @State private var infoEvent: GameEvent?
    @State private var upgradeConfig = UpgradeConfigLoader.load()
    @State private var gameConfig = GameConfigManager.shared.config
    @State private var selectedDifficultyId = "normal"

    private var events: [GameEvent] {
        eventManager.events(forCategoryId: selectedCategoryId, mode: .main)
    }

    private var categories: [EventCategoryInfo] {
        eventManager.categories.isEmpty
            ? [
                EventCategoryInfo(id: "boss", title: "Boss"),
                EventCategoryInfo(id: "story", title: "Trials"),
                EventCategoryInfo(id: "special", title: "Special"),
            ]
            : eventManager.categories
    }

    private var eventUI: EventUIConfig {
        gameConfig.eventUI ?? .fallback
    }

    private var rewardIcons: EventRewardIconConfig {
        eventUI.rewardIcons ?? .fallback
    }

    var body: some View {
        VStack(spacing: 14) {
            categoryBar

            ScrollView {
                VStack(spacing: 14) {
                    if events.isEmpty {
                        emptyState
                    } else {
                        ForEach(events) { event in
                            eventCard(event)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(
            eventUI.title ?? EventUIConfig.fallback.title ?? "Events"
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            eventManager.load()
            upgradeConfig = UpgradeConfigLoader.load()
            gameConfig = GameConfigManager.shared.config
            selectedCategoryId = categories.first?.id ?? "boss"
            selectedDifficultyId =
                gameConfig.battleDifficulties.first?.id ?? "normal"
        }
        .sheet(item: $infoEvent) { event in
            eventInfoSheet(event)
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        Text(category.title.uppercased())
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selectedCategoryId == category.id
                                    ? MontamPalette.black : .white
                            )
                            .padding(.horizontal, 16)
                            .frame(height: 38)
                            .background(
                                selectedCategoryId == category.id
                                    ? MontamPalette.gold
                                    : MontamPalette.panel
                            )
                            .clipShape(
                                MontamEvolutionShape()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            RemoteAssetImage(
                name: eventUI.emptyIcon
                    ?? EventUIConfig.fallback.emptyIcon
                    ?? "montam_icon"
            )
            .scaledToFit()
            .frame(width: 82, height: 82)
            .opacity(0.7)

            Text(eventUI.emptyTitle ?? EventUIConfig.fallback.emptyTitle ?? "")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 90)
    }

    private func eventCard(_ event: GameEvent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                RemoteAssetImage(name: event.icon ?? "montam_icon")
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(MontamCutRectangle(cut: 12))

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        eventBadge(event.category.rawValue.uppercased())
                        if event.type == "skin" {
                            eventBadge(
                                eventUI.skinBadgeTitle
                                    ?? EventUIConfig.fallback.skinBadgeTitle
                                    ?? "SKIN MONTAM CONTAINERS"
                            )
                        }
                        if event.rewards?.eggs?.isEmpty == false {
                            eventBadge(
                                eventUI.eggBadgeTitle
                                    ?? EventUIConfig.fallback.eggBadgeTitle
                                    ?? "EGG DROP"
                            )
                        }
                    }

                    Text(event.title.uppercased())
                        .font(
                            .system(size: 17, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(
                        (event.description
                            ?? eventUI.defaultDescription
                            ?? EventUIConfig.fallback.defaultDescription
                            ?? "Event Battle").uppercased()
                    )
                    .font(
                        .system(size: 10, weight: .bold, design: .rounded)
                    )
                    .foregroundStyle(MontamPalette.mutedText)
                    .lineLimit(2)

                    Text(countdownText(for: event).uppercased())
                        .font(
                            .system(size: 10, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.gold)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    infoEvent = event
                } label: {
                    Text("i")
                        .font(
                            .system(size: 14, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.black)
                        .frame(width: 30, height: 30)
                        .background(MontamPalette.gold)
                        .clipShape(MontamCutRectangle(cut: 8))
                }
                .buttonStyle(.plain)
            }

            rewardStrip(event)

            difficultyRow(event)

            if let storyText = event.storyText {
                Text(storyText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(3)
            }

            Button {
                start(event)
            } label: {
                Text(
                    eventUI.battleButtonTitle
                        ?? EventUIConfig.fallback.battleButtonTitle
                        ?? "MONTAM CONTAINERS BATTLE"
                )
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(MontamPalette.gold)
                .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(MontamPalette.panel)
        .overlay(
            MontamEvolutionShape()
                .stroke(
                    event.category == .boss
                        ? MontamPalette.gold : MontamPalette.blue,
                    lineWidth: 1.8
                )
        )
        .clipShape(MontamEvolutionShape())
    }

    private func eventBadge(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 8, weight: .black, design: .rounded))
            .foregroundStyle(MontamPalette.black)
            .padding(.horizontal, 7)
            .frame(height: 20)
            .background(MontamPalette.gold)
            .clipShape(MontamEvolutionShape())
    }

    private func difficultyRow(_ event: GameEvent) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(difficulties(for: event)) { difficulty in
                    let selected = selectedDifficultyId == difficulty.id

                    Button {
                        selectedDifficultyId = difficulty.id
                    } label: {
                        Text(difficulty.title.uppercased())
                            .font(
                                .system(
                                    size: 10,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selected ? MontamPalette.black : .white
                            )
                            .padding(.horizontal, 12)
                            .frame(height: 32)
                            .background(
                                selected
                                    ? MontamPalette.gold
                                    : MontamPalette.black.opacity(0.62)
                            )
                            .clipShape(
                                MontamEvolutionShape()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func rewardStrip(_ event: GameEvent) -> some View {
        HStack(spacing: 7) {
            rewardChip(
                "montamCoins",
                event.rewards?.montamCoins,
                icon: rewardIcons.montamCoins
            )
            rewardChip(
                "montamSaphirs",
                event.rewards?.montamSaphirs,
                icon: rewardIcons.montamSaphirs
            )
            rewardChip(
                "montamRubys",
                event.rewards?.montamRubys,
                icon: rewardIcons.montamRubys
            )
            rewardChip(
                "montamContainers",
                event.rewards?.montamContainers,
                icon: rewardIcons.montamContainers
            )
            rewardChip(
                "montamLiquid",
                event.rewards?.montamLiquid,
                icon: rewardIcons.montamLiquid
            )
            if let egg = event.rewards?.eggs?.first {
                MontamRewardChip(
                    title: "EGG",
                    value: egg.amount,
                    icon: eggIcon(for: egg.eggId)
                )
            }
            if let medals = event.rewards?.medals,
                let medal = medalDefinition(for: event.rewards?.medalId)
            {
                MontamRewardChip(
                    title: medal.title,
                    value: medals,
                    icon: medal.icon
                )
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func rewardChip(_ title: String, _ value: Int?, icon: String)
        -> some View
    {
        if let value {
            MontamRewardChip(title: title, value: value, icon: icon)
        }
    }

    private func medalDefinition(for medalId: String?) -> MontamMedalDefinition?
    {
        guard let medalId else { return nil }
        return upgradeConfig.medalDefinitions.first { $0.id == medalId }
    }

    private func eventInfoSheet(_ event: GameEvent) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                RemoteAssetImage(name: event.icon ?? "montam_icon")
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 5) {
                    Text(event.title.uppercased())
                        .font(
                            .system(size: 20, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(
                        "\(eventUI.infoElementPrefix ?? EventUIConfig.fallback.infoElementPrefix ?? "Element") \(MontamElement.parse(event.enemyElement).title)"
                    )
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)

                    Text(countdownText(for: event).uppercased())
                        .font(
                            .system(size: 10, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.blue)
                }
            }

            Text(
                event.description
                    ?? eventUI.defaultDescription
                    ?? EventUIConfig.fallback.defaultDescription
                    ?? "Event Battle"
            )
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)

            if let storyText = event.storyText {
                Text(storyText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
            }

            if let medal = medalDefinition(for: event.rewards?.medalId),
                let medals = event.rewards?.medals
            {
                MontamRewardLine(
                    title: medal.title.uppercased(),
                    value: medals,
                    icon: medal.icon
                )
            }

            Text(
                eventUI.infoElementRules
                    ?? EventUIConfig.fallback.infoElementRules
                    ?? ""
            )
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)

            Spacer()
        }
        .padding(24)
        .background(MontamScreenBackground())
    }

    private func start(_ event: GameEvent) {
        appModel.startEventBattle(
            event: event,
            difficulty: selectedDifficulty(for: event)
        )
    }

    private func difficulties(for event: GameEvent) -> [BattleDifficulty] {
        let all =
            gameConfig.battleDifficulties.isEmpty
            ? GameConfig.fallback.battleDifficulties
            : gameConfig.battleDifficulties
        guard let ids = event.difficultyIds, !ids.isEmpty else { return all }
        let filtered = all.filter { ids.contains($0.id) }
        return filtered.isEmpty ? all : filtered
    }

    private func selectedDifficulty(for event: GameEvent) -> BattleDifficulty {
        difficulties(for: event).first { $0.id == selectedDifficultyId }
            ?? difficulties(for: event)[0]
    }

    private func countdownText(for event: GameEvent) -> String {
        guard let endDate = date(from: event.endDate) else {
            return eventUI.permanentText
                ?? EventUIConfig.fallback.permanentText
                ?? "Permanent"
        }

        let seconds = max(0, Int(endDate.timeIntervalSinceNow))
        if seconds == 0 {
            return eventUI.endedText ?? EventUIConfig.fallback.endedText
                ?? "Ended"
        }

        let days = seconds / 86_400
        let hours = (seconds % 86_400) / 3_600
        if days > 0 {
            return
                "\(days)d \(hours)h \(eventUI.dayLeftSuffix ?? EventUIConfig.fallback.dayLeftSuffix ?? "left")"
        }
        let minutes = (seconds % 3_600) / 60
        return
            "\(hours)h \(minutes)m \(eventUI.hourLeftSuffix ?? EventUIConfig.fallback.hourLeftSuffix ?? "left")"
    }

    private func date(from string: String?) -> Date? {
        MontamDateParser.date(from: string)
    }

    private func eggIcon(for eggId: String) -> String {
        EggConfigLoader.load().eggs.first(where: { $0.id == eggId })?.eggImage
            ?? rewardIcons.egg
    }
}

#Preview {
    NavigationStack {
        EventView()
            .environmentObject(AppModel())
            .environmentObject(EventManager.shared)
    }
}
