//
//  WardrobeView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct WardrobeView: View {
    @ObservedObject var teamManager: TeamManager
    @ObservedObject private var skinInventory = SkinInventoryManager.shared

    @State private var skins: [MontamSkinDefinition] = []
    @State private var characters: [Character] = []
    @State private var selectedCharacterId: String?
    @State private var selectedSkinInfo: MontamSkinDefinition?

    private var ownedCharacters: [OwnedCharacter] {
        teamManager.ownedCharacters
    }

    private var skinCharacterIds: [String] {
        var seen: Set<String> = []
        return skins.compactMap { skin in
            guard !seen.contains(skin.characterId) else { return nil }
            seen.insert(skin.characterId)
            return skin.characterId
        }
    }

    private var activeCharacterId: String? {
        selectedCharacterId ?? skinCharacterIds.first
    }

    private var visibleSkins: [MontamSkinDefinition] {
        guard let activeCharacterId else { return [] }
        return skins.filter { $0.characterId == activeCharacterId }
    }

    var body: some View {
        VStack(spacing: 14) {
            characterStrip

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(visibleSkins) { skin in
                        skinCard(skin)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 18)
        .background {
            MontamBackground()
        }
        .navigationTitle("Wardrobe")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedSkinInfo) { skin in
            skinInfoSheet(skin)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            skins = SkinConfigLoader.load().skins
            characters = (try? JSONLoader.load("characters")) ?? []
            selectedCharacterId =
                selectedCharacterId ?? skinCharacterIds.first
        }
    }

    private var characterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(skinCharacterIds, id: \.self) { characterId in
                    let selected = activeCharacterId == characterId
                    let character = character(for: characterId)
                    let owned = ownsCharacter(characterId)
                    let image = characterImage(for: characterId)

                    Button {
                        selectedCharacterId = characterId
                    } label: {
                        VStack(spacing: 5) {
                            RemoteAssetImage(name: image)
                                .scaledToFit()
                                .frame(width: 54, height: 54)
                                .opacity(owned ? 1 : 0.45)

                            Text((character?.name ?? characterId).uppercased())
                                .font(
                                    .system(
                                        size: 9,
                                        weight: .black,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)

                            if !owned {
                                Text("LOCKED")
                                    .font(
                                        .system(
                                            size: 7,
                                            weight: .black,
                                            design: .rounded
                                        )
                                    )
                                    .foregroundStyle(MontamPalette.gold)
                            }
                        }
                        .frame(width: 92, height: 82)
                        .background(
                            selected
                                ? MontamPalette.gold.opacity(0.25)
                                : MontamPalette.panel
                        )
                        .clipShape(MontamCutRectangle(cut: 14))
                        .overlay(
                            MontamCutRectangle(cut: 14)
                                .stroke(
                                    selected
                                        ? MontamPalette.gold
                                        : MontamPalette.blue.opacity(0.65),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func skinCard(_ skin: MontamSkinDefinition) -> some View {
        let unlocked = skinInventory.isUnlocked(skin)
        let characterOwned = ownsCharacter(skin.characterId)
        let equipped =
            skinInventory.equippedSkinId(for: skin.characterId) == skin.id

        return HStack(spacing: 14) {
            RemoteAssetImage(name: skin.image)
                .scaledToFit()
                .frame(width: 92, height: 92)
                .opacity(unlocked ? 1 : 0.35)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 7) {
                    Text(skin.title.uppercased())
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(skin.rarity.evolutionStageTitle.uppercased())
                        .font(
                            .system(size: 8, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(skin.rarity.color)

                    if skin.isEventLimited == true {
                        Text("MONTAM CONTAINERS")
                            .font(
                                .system(
                                    size: 8,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(MontamPalette.black)
                            .padding(.horizontal, 7)
                            .frame(height: 20)
                            .background(MontamPalette.gold)
                            .clipShape(
                                MontamEvolutionShape()
                            )
                    }

                    Spacer(minLength: 0)

                    Button {
                        selectedSkinInfo = skin
                    } label: {
                        RemoteAssetImage(
                            name: "icon_info",
                            fallbackSystemName: "info.circle.fill"
                        )
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                }

                Text(skinDetailText(skin, characterOwned: characterOwned))
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .lineLimit(2)

                if skin.isEventLimited == true {
                    Text(countdownText(endDate: skin.endDate).uppercased())
                        .font(
                            .system(size: 10, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(MontamPalette.gold)
                }

                Button {
                    skinInventory.equip(skin)
                } label: {
                    Text(
                        equipped
                            ? "EQUIPPED"
                            : characterOwned && unlocked
                                ? "EQUIP"
                                : unlockLabel(
                                    for: skin,
                                    characterOwned: characterOwned
                                )
                    )
                    .font(
                        .system(size: 11, weight: .black, design: .rounded)
                    )
                    .foregroundStyle(
                        characterOwned && unlocked
                            ? MontamPalette.black
                            : MontamPalette.mutedText
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        characterOwned && unlocked
                            ? MontamPalette.gold
                            : MontamPalette.black
                    )
                    .clipShape(MontamEvolutionShape())
                }
                .buttonStyle(.plain)
                .disabled(!characterOwned || !unlocked || equipped)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
        .overlay(
            MontamCutRectangle(cut: 18)
                .stroke(
                    equipped
                        ? MontamPalette.gold
                        : skin.rarity.color.opacity(0.75),
                    lineWidth: equipped ? 2 : 1.4
                )
        )
    }

    private func countdownText(endDate: String?) -> String {
        guard let endDate = date(from: endDate) else { return "Permanent" }
        let seconds = max(0, Int(endDate.timeIntervalSinceNow))
        if seconds == 0 { return "Ended" }
        let days = seconds / 86_400
        let hours = (seconds % 86_400) / 3_600
        if days > 0 { return "\(days)d \(hours)h left" }
        let minutes = (seconds % 3_600) / 60
        return "\(hours)h \(minutes)m left"
    }

    private func date(from string: String?) -> Date? {
        MontamDateParser.date(from: string)
    }

    private func skinInfoSheet(_ skin: MontamSkinDefinition) -> some View {
        let characterOwned = ownsCharacter(skin.characterId)
        let unlocked = skinInventory.isUnlocked(skin)
        let character = character(for: skin.characterId)

        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 16) {
                    RemoteAssetImage(name: skin.image)
                        .scaledToFit()
                        .frame(width: 118, height: 118)
                        .opacity(unlocked ? 1 : 0.45)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(skin.title.uppercased())
                            .font(
                                .system(
                                    size: 22,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)

                        Text((character?.name ?? skin.characterId).uppercased())
                            .font(
                                .system(
                                    size: 12,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(MontamPalette.gold)

                        Text(skin.rarity.evolutionStageTitle.uppercased())
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(skin.rarity.color)
                    }
                }

                infoRow(
                    "STATUS",
                    value: skinStatusText(
                        skin,
                        characterOwned: characterOwned,
                        unlocked: unlocked
                    )
                )
                infoRow("QUELLE", value: skin.source ?? "Rewards")

                if let description = skin.description {
                    infoRow("DETAILS", value: description)
                }

                if skin.isEventLimited == true {
                    infoRow("START", value: skin.startDate ?? "Unbekannt")
                    infoRow("ENDE", value: skin.endDate ?? "Unbekannt")
                    infoRow(
                        "COUNTDOWN",
                        value: countdownText(endDate: skin.endDate)
                    )
                }
            }
            .padding(22)
        }
        .background(MontamScreenBackground())
    }

    private func infoRow(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            Text(value.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 14))
        .overlay(
            MontamCutRectangle(cut: 14)
                .stroke(MontamPalette.blue.opacity(0.65), lineWidth: 1)
        )
    }

    private func character(for id: String) -> Character? {
        characters.first { $0.id == id }
    }

    private func ownsCharacter(_ id: String) -> Bool {
        ownedCharacters.contains { $0.baseId == id }
    }

    private func characterImage(for id: String) -> String {
        if let owned = ownedCharacters.first(where: { $0.baseId == id }) {
            return SkinInventoryManager.shared.activeImage(for: owned.base)
        }

        if let defaultSkin = skins.first(where: {
            $0.characterId == id && $0.id == "default"
        }) {
            return defaultSkin.image
        }

        return character(for: id)?.sprite ?? "montam_icon"
    }

    private func skinDetailText(
        _ skin: MontamSkinDefinition,
        characterOwned: Bool
    ) -> String {
        let source = skin.source ?? "Rewards"
        let ownership =
            characterOwned ? source : "Montam noch nicht freigeschaltet"
        let description = skin.description ?? source
        return "\(description) • \(ownership)".uppercased()
    }

    private func unlockLabel(
        for skin: MontamSkinDefinition,
        characterOwned: Bool
    ) -> String {
        guard characterOwned else { return "MONTAM LOCKED" }
        guard let source = skin.source?.lowercased() else { return "LOCKED" }
        if source.contains("shop") || source.contains("kaufen") {
            return "SHOP"
        }
        if source.contains("pass") {
            return "PASS"
        }
        if source.contains("event") {
            return "MONTAM CONTAINERS"
        }
        if source.contains("gift") {
            return "GIFT"
        }
        return "LOCKED"
    }

    private func skinStatusText(
        _ skin: MontamSkinDefinition,
        characterOwned: Bool,
        unlocked: Bool
    ) -> String {
        if !characterOwned {
            return "Montam noch nicht freigeschaltet"
        }
        if unlocked {
            return "Freigeschaltet"
        }
        return unlockLabel(for: skin, characterOwned: characterOwned)
    }
}

#Preview {
    WardrobeView(teamManager: TeamManager())
}
