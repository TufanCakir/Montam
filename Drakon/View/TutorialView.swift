//
//  TutorialView.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
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
                    .foregroundStyle(DrakonBladePalette.gold)

                Text(step.text)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.mutedText)
                    .multilineTextAlignment(.center)
            }
            .padding(18)
            .background(DrakonBladePalette.panel)
            .clipShape(DrakonCutRectangle(cut: 18))

            Button {
                advance()
            } label: {
                Text(index == tutorial.steps.count - 1 ? "STARTEN" : "WEITER")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(DrakonBladePalette.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(DrakonBladePalette.gold)
                    .clipShape(DrakonBladeShape(pointDepth: 28, slant: 14))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 22)
        .background(DrakonScreenBackground())
        .onAppear {
            tutorial = TutorialConfigLoader.load()
        }
    }

    private var battlePreview: some View {
        VStack(spacing: 14) {
            RemoteAssetImage(name: "skin_solarion_imperial_default")
                .scaledToFit()
                .frame(height: 116)

            HStack(spacing: 10) {
                ForEach(tutorial.previewForms, id: \.self) { form in
                    RemoteAssetImage(name: form)
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 62)
                        .padding(8)
                        .background(DrakonBladePalette.panel)
                        .clipShape(DrakonCutRectangle(cut: 12))
                }
            }

            Text("TUTORIAL: ALLE FORMS FREI")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(DrakonBladePalette.gold)
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
