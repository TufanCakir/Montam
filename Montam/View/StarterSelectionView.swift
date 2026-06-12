//
//  StarterSelectionView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct StarterSelectionView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var config: StarterEggConfig = StarterEggConfig(
        title: "Wähle deinen Starter",
        subtitle: "Diese Auswahl ist nur einmal pro Account möglich.",
        eggs: []
    )
    @State private var selectedEggIds: Set<String> = []

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    private var selectionLimit: Int {
        max(1, GameConfigManager.shared.config.starterSelection.selectionCount)
    }

    private var selectedEggs: [StarterEgg] {
        config.eggs.filter { selectedEggIds.contains($0.id) }
    }

    var body: some View {

        VStack(spacing: 18) {
            header

            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 142), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(config.eggs) { egg in
                        eggCard(egg)
                    }
                }
                .padding(.vertical, 8)
            }

            confirmButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 26)
        .onAppear(perform: loadConfig)
        .background {
            MontamBackground()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 84, height: 84)

            Text(config.title.uppercased())
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(config.subtitle)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(mutedText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

        }
    }

    private var confirmButton: some View {
        Button {
            confirmSelection()
        } label: {
            ZStack(alignment: .leading) {
                StarterBladeShape(pointDepth: 34, slant: 16)
                    .fill(canConfirm ? gold : panel)
                    .overlay(
                        StarterBladeShape(pointDepth: 34, slant: 16)
                            .stroke(
                                canConfirm ? blue : Color.white.opacity(0.12),
                                lineWidth: 2
                            )
                    )

                HStack(spacing: 14) {
                    RemoteAssetImage(
                        name: selectedEggs.first?.previewImage ?? "montam_icon"
                    )
                    .scaledToFit()
                    .frame(width: 46, height: 46)
                    .opacity(canConfirm ? 1 : 0.45)

                    Text(canConfirm ? "Starter wählen" : "Starter auswählen")
                        .font(
                            .system(.headline, design: .rounded, weight: .black)
                        )
                        .foregroundStyle(
                            canConfirm ? black : .white.opacity(0.54)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Spacer()
                }
                .padding(.leading, 18)
                .padding(.trailing, 30)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .disabled(!canConfirm)
    }

    private var canConfirm: Bool {
        selectedEggIds.count == selectionLimit
    }

    private func eggCard(_ egg: StarterEgg) -> some View {
        let isSelected = selectedEggIds.contains(egg.id)
        let tint = color(for: egg.accentColor)

        return Button {
            toggleSelection(egg)
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    StarterAngledRectangle(cut: 18)
                        .fill(panel)
                        .frame(height: 138)
                        .overlay(
                            StarterAngledRectangle(cut: 18)
                                .stroke(
                                    isSelected
                                        ? tint : Color.white.opacity(0.12),
                                    lineWidth: isSelected ? 3 : 1
                                )
                        )

                    RemoteAssetImage(name: egg.eggImage)
                        .scaledToFit()
                        .frame(width: 104, height: 104)
                        .scaleEffect(isSelected ? 1.08 : 1)
                }

                Text(egg.title.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                RemoteAssetImage(name: egg.previewImage)
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .opacity(0.82)
            }
            .padding(10)
            .background(black.opacity(0.45))
            .clipShape(StarterAngledRectangle(cut: 18))
        }
        .buttonStyle(.plain)
    }

    private func loadConfig() {
        do {
            config = try JSONLoader.load("starter_eggs")
        } catch {
            print("Starter eggs load failed:", error)
        }
    }

    private func toggleSelection(_ egg: StarterEgg) {
        if selectedEggIds.contains(egg.id) {
            selectedEggIds.remove(egg.id)
            return
        }

        if selectionLimit == 1 {
            selectedEggIds = [egg.id]
            return
        }

        guard selectedEggIds.count < selectionLimit else { return }
        selectedEggIds.insert(egg.id)
    }

    private func confirmSelection() {
        guard canConfirm else { return }

        let characterIds =
            selectedEggs
            .prefix(selectionLimit)
            .map(\.characterId)

        appModel.chooseStarters(characterIds: characterIds)
    }

    private func color(for value: String) -> Color {
        switch value.lowercased() {
        case "blue":
            blue
        case "gold":
            gold
        default:
            gold
        }
    }
}

private struct StarterBladeShape: Shape {
    let pointDepth: CGFloat
    let slant: CGFloat

    func path(in rect: CGRect) -> Path {
        let pointDepth = min(pointDepth, rect.width * 0.22)
        let slant = min(slant, rect.height * 0.38)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct StarterAngledRectangle: Shape {
    let cut: CGFloat

    func path(in rect: CGRect) -> Path {
        let cut = min(cut, min(rect.width, rect.height) / 2)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
        path.closeSubpath()
        return path
    }
}

#Preview {
    StarterSelectionView()
        .environmentObject(AppModel())
}
