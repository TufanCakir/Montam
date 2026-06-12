//
//  HatcheryView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct HatcheryView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var eggInventory = EggInventoryManager.shared
    @ObservedObject private var montamLiquidManager = MontamLiquidManager.shared

    @State private var eggs: [MontamEgg] = []
    @State private var hatchedEgg: MontamEgg?
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
            RemoteAssetImage(name: "egg_feral_cryon")
                .scaledToFit()
                .frame(width: 92, height: 92)

            Text("MONTAM EGGS")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            HStack(spacing: 8) {
                RemoteAssetImage(name: "icon_montam_liquid")
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text("MONTAM LIQUID \(montamLiquidManager.montamLiquid)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 12)
            .frame(height: 38)
            .background(MontamPalette.panel)
            .clipShape(MontamEvolutionShape())

            if let message {
                Text(message)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var emptyState: some View {
        Text("KEINE EIER VERFUGBAR")
            .font(.system(size: 14, weight: .black, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)
            .frame(maxWidth: .infinity)
            .frame(height: 110)
            .background(MontamPalette.panel)
            .clipShape(MontamCutRectangle(cut: 18))
    }

    private func eggRow(_ egg: MontamEgg) -> some View {
        let owned = eggInventory.count(for: egg.id)
        let canHatch =
            owned > 0
            && montamLiquidManager.montamLiquid >= egg.hatchCostMontamLiquid

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
                            .foregroundStyle(MontamPalette.black)
                            .padding(.horizontal, 8)
                            .frame(height: 22)
                            .background(MontamPalette.gold)
                            .clipShape(
                                MontamEvolutionShape()
                            )
                    }

                    Text(egg.title.uppercased())
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text(
                        (egg.description ?? "Schlüpft zu einem Montam.")
                            .uppercased()
                    )
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .lineLimit(2)

                    HStack(spacing: 10) {
                        pill(
                            "OWNED \(owned)",
                            icon: egg.eggImage,
                            tint: MontamPalette.blue
                        )
                        pill(
                            "\(egg.hatchCostMontamLiquid)",
                            icon: "icon_montam_liquid",
                            tint: MontamPalette.gold
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
                            ? MontamPalette.black
                            : MontamPalette.mutedText
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        canHatch
                            ? MontamPalette.gold : MontamPalette.black
                    )
                    .clipShape(MontamEvolutionShape())
                    .overlay(
                        MontamEvolutionShape()
                            .stroke(
                                canHatch
                                    ? MontamPalette.blue
                                    : .white.opacity(0.10),
                                lineWidth: 1.5
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canHatch)
        }
        .padding(14)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
        .overlay(
            MontamCutRectangle(cut: 18)
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
        .background(MontamPalette.black)
        .clipShape(MontamEvolutionShape())
        .overlay(
            MontamEvolutionShape()
                .stroke(tint, lineWidth: 1)
        )
    }

    private func hatch(_ egg: MontamEgg) {
        guard eggInventory.consume(1, eggId: egg.id) else {
            message = "Du hast dieses Ei nicht."
            return
        }

        guard montamLiquidManager.spend(egg.hatchCostMontamLiquid) else {
            EggInventoryManager.shared.add(1, eggId: egg.id)
            message = "Nicht genug MontamLiquid."
            return
        }

        do {
            let characters: [Character] = try JSONLoader.load("characters")
            guard
                let feral = characters.first(where: { $0.id == egg.characterId }
                )
            else {
                EggInventoryManager.shared.add(1, eggId: egg.id)
                MontamLiquidManager.shared.add(egg.hatchCostMontamLiquid)
                message = "Montam nicht gefunden."
                return
            }

            appModel.teamManager.addOwnedCharacter(OwnedCharacter(base: feral))
            hatchedEgg = egg
            message = "\(feral.name) ist geschlüpft."
        } catch {
            EggInventoryManager.shared.add(1, eggId: egg.id)
            MontamLiquidManager.shared.add(egg.hatchCostMontamLiquid)
            message = "characters.json konnte nicht geladen werden."
        }
    }

    private func hatchResult(egg: MontamEgg) -> some View {
        VStack(spacing: 14) {
            RemoteAssetImage(name: egg.eggImage)
                .scaledToFit()
                .frame(width: 86, height: 86)

            RemoteAssetImage(name: egg.feralImage)
                .scaledToFit()
                .frame(width: 132, height: 132)

            Text("HATCHED")
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            Text(egg.title.uppercased())
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Button {
                hatchedEgg = nil
            } label: {
                Text("OK")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(MontamPalette.gold)
                    .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .frame(maxWidth: 310)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 22))
        .overlay(
            MontamCutRectangle(cut: 22)
                .stroke(MontamPalette.gold, lineWidth: 2)
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
        MontamDateParser.date(from: string)
    }
}

#Preview {
    HatcheryView()
        .environmentObject(AppModel())
}
