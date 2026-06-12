//
//  CharacterDetailView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct CharacterDetailView: View {
    let owned: OwnedCharacter

    private var element: MontamElement {
        MontamElement.parse(owned.base.energyType)
    }

    private var expRatio: Double {
        guard owned.requiredEXP > 0 else { return 0 }
        return min(1, Double(owned.exp) / Double(owned.requiredEXP))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                heroSection
                progressionSection
                statsSection
                skillsSection
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(MontamScreenBackground())
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            RemoteAssetImage(
                name: SkinInventoryManager.shared.activeImage(for: owned.base)
            )
            .scaledToFit()
            .frame(height: 190)

            Text(owned.base.name.uppercased())
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                detailPill("LV \(owned.level)", tint: MontamPalette.gold)
                detailPill(
                    owned.base.rarity.evolutionStageTitle.uppercased(),
                    tint: owned.base.rarity.color
                )
                detailPill(element.title, tint: MontamPalette.blue)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 22))
        .overlay(
            MontamCutRectangle(cut: 22)
                .stroke(owned.starColor, lineWidth: 2)
        )
    }

    private var progressionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("STARS")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)

                Spacer()

                Text("\(owned.stars) / \(OwnedCharacter.maxStars)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            MontamStarRow(stars: owned.stars, size: 18)

            if owned.stars >= 7 {
                Text(
                    owned.isMaxStar
                        ? "MAX AWAKENED" : "SECOND STAR LINE UNLOCKED"
                )
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.blue)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("EXP")
                    Spacer()
                    Text("\(owned.exp) / \(owned.requiredEXP)")
                }
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)

                ProgressView(value: expRatio)
                    .progressViewStyle(.linear)
                    .tint(MontamPalette.gold)
                    .scaleEffect(x: 1, y: 1.7, anchor: .center)
            }
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            statRow("HP", base: owned.base.stats.hp, total: owned.totalHP)
            statRow(
                "ATTACK",
                base: owned.base.stats.attack,
                total: owned.totalAttack
            )
            statRow(
                "ENERGY",
                base: owned.base.stats.energyPower,
                total: owned.totalEnergyPower
            )
            statRow(
                "SPEED",
                value: String(format: "%.2f", owned.base.stats.attackSpeed)
            )
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
    }

    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SKILLS")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)

            ForEach(owned.base.skills, id: \.id) { skill in
                skillRow(skill)
            }
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamCutRectangle(cut: 18))
    }

    private func detailPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(MontamPalette.black)
            .clipShape(MontamEvolutionShape())
            .overlay(
                MontamEvolutionShape()
                    .stroke(tint, lineWidth: 1)
            )
    }

    private func statRow(_ title: String, base: Int, total: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)

            Spacer()

            Text("\(total)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("BASE \(base)")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)
        }
        .padding(12)
        .background(MontamPalette.black)
        .clipShape(MontamEvolutionShape())
    }

    private func statRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(MontamPalette.black)
        .clipShape(MontamEvolutionShape())
    }

    private func skillRow(_ skill: Skill) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(skill.name.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Text("x\(String(format: "%.1f", skill.multiplier))")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)
            }

            Text(
                "\(skill.type.rawValue.uppercased())  COOLDOWN \(Int(skill.cooldown ?? 0))"
            )
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)
        }
        .padding(12)
        .background(MontamPalette.black)
        .clipShape(MontamEvolutionShape())
    }
}

#Preview {
    CharacterDetailView(
        owned: OwnedCharacter(
            base: Character(
                id: "preview",
                name: "Pyro",
                rarity: .common,
                role: "dps",
                skills: [],
                stats: Character.Stats(
                    hp: 900,
                    attack: 85,
                    energyPower: 45,
                    attackSpeed: 1.6
                ),
                energyType: "fire",
                sprite: "skin_pyro_feral_default",
                skins: []
            )
        )
    )
}
