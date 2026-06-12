//
//  SummonResultView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct SummonResultView: View {
    let characters: [Character]

    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.adaptive(minimum: 128), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 14) {
            header

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(characters.enumerated()), id: \.offset) {
                        _,
                        character in
                        summonCard(character)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
            .scrollIndicators(.hidden)

            Button {
                dismiss()
            } label: {
                Text("WEITER")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(MontamPalette.gold)
                    .overlay(
                        MontamEggShape()
                            .stroke(MontamPalette.blue, lineWidth: 2)
                    )
                    .clipShape(MontamEggShape())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .padding(.top, 18)
        .background(MontamScreenBackground())
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: 14) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 4) {
                Text("SUMMON RESULT")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1)

                Text("\(characters.count) MONTAM")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func summonCard(_ character: Character) -> some View {
        VStack(spacing: 10) {
            ZStack {
                MontamCutRectangle(cut: 18)
                    .fill(MontamPalette.black)
                    .frame(height: 112)
                    .overlay(
                        MontamCutRectangle(cut: 18)
                            .stroke(character.rarity.color, lineWidth: 1.8)
                    )

                RemoteAssetImage(name: character.sprite)
                    .scaledToFit()
                    .frame(width: 96, height: 96)
            }

            VStack(spacing: 5) {
                Text(character.name.uppercased())
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Text(character.rarity.evolutionStageTitle.uppercased())
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(character.rarity.color)
                    .padding(.horizontal, 9)
                    .frame(height: 22)
                    .background(MontamPalette.black)
                    .clipShape(MontamEggShape())
            }
        }
        .padding(10)
        .background(MontamPalette.panel)
        .overlay(
            MontamEggShape()
                .stroke(character.rarity.color, lineWidth: 1.6)
        )
        .clipShape(MontamEggShape())
    }
}

#Preview {
    SummonResultView(characters: [])
}
