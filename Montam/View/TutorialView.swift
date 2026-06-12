//
//  TutorialView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct TutorialView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var tutorial = TutorialConfigLoader.load()
    @State private var index = 0

    private var step: TutorialStepConfig {
        tutorial.steps.indices.contains(index)
            ? tutorial.steps[index] : tutorial.steps[0]
    }

    private var starterCharacter: OwnedCharacter? {
        appModel.teamManager.activeTeam.first
            ?? appModel.teamManager.ownedCharacters.first
    }

    private var starterImage: String {
        guard let starterCharacter else {
            return "skin_cryon_feral_default"
        }

        return SkinInventoryManager.shared.activeImage(for: starterCharacter.base)
    }

    private var dynamicPreviewForms: [String] {
        guard let starterCharacter else {
            return tutorial.previewForms
        }

        return evolutionForms(for: starterCharacter.baseId)
    }

    private func evolutionForms(for characterId: String) -> [String] {
        let id = characterId.lowercased()

        if id.contains("cryon")
            || id.contains("crygon")
            || id.contains("stormeon")
            || id.contains("imperion")
        {
            return [
                "skin_cryon_feral_default",
                "skin_crygon_tamed_default",
                "skin_stormeon_mastered_default",
                "skin_imperion_exalted_default",
            ]
        }

        if id.contains("pyron")
            || id.contains("blazion")
            || id.contains("infernon")
            || id.contains("solarion")
        {
            return [
                "skin_pyron_feral_default",
                "skin_blazion_tamed_default",
                "skin_infernon_mastered_default",
                "skin_solarion_exalted_default",
            ]
        }

        return [starterImage] + tutorial.previewForms.filter {
            $0 != starterImage
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            Text(tutorial.title.uppercased())
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 26)

            battlePreview

            VStack(spacing: 8) {
                Text(step.title.uppercased())
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)

                Text(step.text)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(MontamPalette.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(18)
            .background(MontamPalette.panel)
            .clipShape(MontamCutRectangle(cut: 18))

            Button {
                advance()
            } label: {
                Text(index == tutorial.steps.count - 1 ? "STARTEN" : "WEITER")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(MontamPalette.gold)
                    .clipShape(MontamEvolutionShape())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 22)
        .onAppear {
            tutorial = TutorialConfigLoader.load()
        }
    }

    private var battlePreview: some View {
        VStack(spacing: 14) {
            RemoteAssetImage(name: starterImage)
                .scaledToFit()
                .frame(height: 116)

            HStack(spacing: 10) {
                ForEach(dynamicPreviewForms, id: \.self) { form in
                    RemoteAssetImage(name: form)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .padding(8)
                        .background(MontamPalette.panel)
                        .clipShape(MontamCutRectangle(cut: 12))
                }
            }

            Text("TUTORIAL: ALLE FORMS FREI")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.gold)
        }
    }

    private func advance() {
        guard index < tutorial.steps.count - 1 else {
            appModel.completeFirstTutorial()
            return
        }
        index += 1
    }
}

#Preview {
    TutorialView()
        .environmentObject(AppModel())
}
