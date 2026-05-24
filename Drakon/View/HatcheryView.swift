//
//  HatcheryView.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import SwiftUI

struct HatcheryView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var eggInventory = EggInventoryManager.shared
    @ObservedObject private var drakenManager = DrakenManager.shared

    @State private var eggs: [DrakonEgg] = []
    @State private var hatchedEgg: DrakonEgg?
    @State private var message: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

                if eggs.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(eggs) { egg in
                            eggRow(egg)
                        }
                    }
                }
            }
            .padding(18)
        }
        .scrollIndicators(.hidden)
        .background(DrakonScreenBackground())
        .navigationTitle("Hatchery")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            eggs = EggConfigLoader.load().eggs
        }
        .overlay {
            if let hatchedEgg {
                hatchResult(egg: hatchedEgg)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            RemoteAssetImage(name: "egg_baby_pyro")
                .scaledToFit()
                .frame(width: 92, height: 92)

            Text("DRAKON EGGS")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(DrakonBladePalette.gold)

            HStack(spacing: 8) {
                RemoteAssetImage(name: "icon_draken")
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text("DRAKEN \(drakenManager.draken)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(DrakonBladePalette.panel)
            .clipShape(DrakonBladeShape(pointDepth: 12, slant: 8))

            if let message {
                Text(message)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.mutedText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var emptyState: some View {
        Text("KEINE EIER VERFUGBAR")
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(DrakonBladePalette.mutedText)
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(DrakonBladePalette.panel)
            .clipShape(DrakonCutRectangle(cut: 18))
    }

    private func eggRow(_ egg: DrakonEgg) -> some View {
        let owned = eggInventory.count(for: egg.id)
        let canHatch = owned > 0 && drakenManager.draken >= egg.hatchCostDraken

        return VStack(spacing: 12) {
            HStack(spacing: 14) {
                RemoteAssetImage(name: egg.eggImage)
                    .scaledToFit()
                    .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 6) {
                    if egg.isLimited == true {
                        Text(countdownText(endDate: egg.endDate).uppercased())
                            .font(
                                .system(
                                    size: 9,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(DrakonBladePalette.black)
                            .padding(.horizontal, 8)
                            .frame(height: 22)
                            .background(DrakonBladePalette.gold)
                            .clipShape(
                                DrakonBladeShape(pointDepth: 8, slant: 5)
                            )
                    }

                    Text(egg.title.uppercased())
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(
                        (egg.description ?? "Schlüpft zu einem Drakon.")
                            .uppercased()
                    )
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.mutedText)
                    .lineLimit(2)

                    HStack(spacing: 10) {
                        pill(
                            "OWNED \(owned)",
                            icon: egg.eggImage,
                            tint: DrakonBladePalette.blue
                        )
                        pill(
                            "\(egg.hatchCostDraken)",
                            icon: "icon_draken",
                            tint: DrakonBladePalette.gold
                        )
                    }
                }

                Spacer(minLength: 0)
            }

            Button {
                hatch(egg)
            } label: {
                Text("EI AUSBRUTEN")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(
                        canHatch
                            ? DrakonBladePalette.black
                            : DrakonBladePalette.mutedText
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        canHatch
                            ? DrakonBladePalette.gold : DrakonBladePalette.black
                    )
                    .clipShape(DrakonBladeShape(pointDepth: 22, slant: 12))
                    .overlay(
                        DrakonBladeShape(pointDepth: 22, slant: 12)
                            .stroke(
                                canHatch
                                    ? DrakonBladePalette.blue
                                    : .white.opacity(0.10),
                                lineWidth: 1.5
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canHatch)
        }
        .padding(14)
        .background(DrakonBladePalette.panel)
        .clipShape(DrakonCutRectangle(cut: 18))
        .overlay(
            DrakonCutRectangle(cut: 18)
                .stroke(egg.rarity.color.opacity(0.9), lineWidth: 1.5)
        )
    }

    private func pill(_ text: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            RemoteAssetImage(name: icon)
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text(text)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .frame(height: 28)
        .background(DrakonBladePalette.black)
        .clipShape(DrakonBladeShape(pointDepth: 9, slant: 6))
        .overlay(
            DrakonBladeShape(pointDepth: 9, slant: 6)
                .stroke(tint, lineWidth: 1)
        )
    }

    private func hatch(_ egg: DrakonEgg) {
        guard eggInventory.consume(1, eggId: egg.id) else {
            message = "Du hast dieses Ei nicht."
            return
        }

        guard drakenManager.spend(egg.hatchCostDraken) else {
            EggInventoryManager.shared.add(1, eggId: egg.id)
            message = "Nicht genug Draken."
            return
        }

        do {
            let characters: [Character] = try JSONLoader.load("characters")
            guard
                let baby = characters.first(where: { $0.id == egg.characterId })
            else {
                EggInventoryManager.shared.add(1, eggId: egg.id)
                DrakenManager.shared.add(egg.hatchCostDraken)
                message = "Drakon nicht gefunden."
                return
            }

            appModel.teamManager.addOwnedCharacter(OwnedCharacter(base: baby))
            hatchedEgg = egg
            message = "\(baby.name) ist geschlüpft."
        } catch {
            EggInventoryManager.shared.add(1, eggId: egg.id)
            DrakenManager.shared.add(egg.hatchCostDraken)
            message = "characters.json konnte nicht geladen werden."
        }
    }

    private func hatchResult(egg: DrakonEgg) -> some View {
        VStack(spacing: 14) {
            RemoteAssetImage(name: egg.eggImage)
                .scaledToFit()
                .frame(width: 86, height: 86)

            RemoteAssetImage(name: egg.babyImage)
                .scaledToFit()
                .frame(width: 132, height: 132)

            Text("HATCHED")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(DrakonBladePalette.gold)

            Text(egg.title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Button {
                hatchedEgg = nil
            } label: {
                Text("OK")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(DrakonBladePalette.gold)
                    .clipShape(DrakonBladeShape(pointDepth: 22, slant: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .frame(maxWidth: 310)
        .background(DrakonBladePalette.panel)
        .clipShape(DrakonCutRectangle(cut: 22))
        .overlay(
            DrakonCutRectangle(cut: 22)
                .stroke(DrakonBladePalette.gold, lineWidth: 2)
        )
        .padding(24)
        .background(.black.opacity(0.72))
    }

    private func countdownText(endDate: String?) -> String {
        guard let endDate = date(from: endDate) else { return "Permanent Egg" }
        let seconds = max(0, Int(endDate.timeIntervalSinceNow))
        if seconds == 0 { return "Ended" }
        let days = seconds / 86_400
        let hours = (seconds % 86_400) / 3_600
        if days > 0 { return "Limited \(days)d \(hours)h" }
        let minutes = (seconds % 3_600) / 60
        return "Limited \(hours)h \(minutes)m"
    }

    private func date(from string: String?) -> Date? {
        DrakonDateParser.date(from: string)
    }
}

#Preview {
    HatcheryView()
        .environmentObject(AppModel())
}
