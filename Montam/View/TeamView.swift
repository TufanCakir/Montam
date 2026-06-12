//
//  TeamView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct TeamView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject var teamManager: TeamManager

    @State private var selectedCharacter: OwnedCharacter?
    @State private var showTeamWarning = false

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    private let columns = [GridItem(.adaptive(minimum: 142), spacing: 14)]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                header
                teamSlots
                collection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(background)
        .sheet(item: $selectedCharacter) { CharacterDetailView(owned: $0) }
        .alert("Team braucht 1 Montam", isPresented: $showTeamWarning) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mindestens ein Montam muss im Team bleiben.")
        }
    }

    private var background: some View {
        black
            .overlay(alignment: .topTrailing) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .opacity(0.055)
                    .offset(x: 64, y: -46)
            }
            .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 14) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 54, height: 54)

            VStack(alignment: .leading, spacing: 4) {
                Text("TEAM")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    "\(teamManager.activeTeam.count) / \(teamManager.maxTeamSize) im Kampf"
                )
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(mutedText)
            }

            Spacer()
        }
        .padding(16)
        .background(panel)
        .overlay(TeamBladeRectangle(cut: 16).stroke(gold, lineWidth: 2))
        .clipShape(TeamBladeRectangle(cut: 16))
    }

    private var teamSlots: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVE TEAM")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(gold)

            HStack(spacing: 10) {
                ForEach(0..<teamManager.maxTeamSize, id: \.self) { index in
                    slot(index)
                }
            }
        }
        .padding(16)
        .background(panel)
        .overlay(TeamBladeRectangle(cut: 16).stroke(blue, lineWidth: 1.6))
        .clipShape(TeamBladeRectangle(cut: 16))
    }

    private func slot(_ index: Int) -> some View {
        ZStack {
            TeamBladeRectangle(cut: 12)
                .fill(black.opacity(0.62))
                .overlay(
                    TeamBladeRectangle(cut: 12).stroke(
                        gold.opacity(0.7),
                        lineWidth: 1.3
                    )
                )

            if teamManager.activeTeam.indices.contains(index) {
                let owned = teamManager.activeTeam[index]
                VStack(spacing: 2) {
                    RemoteAssetImage(
                        name: SkinInventoryManager.shared.activeImage(
                            for: owned.base
                        )
                    )
                    .scaledToFit()
                    .padding(6)

                    MontamStarRow(stars: owned.stars, size: 8)
                        .padding(.bottom, 5)
                }
                .onTapGesture {
                    selectedCharacter = owned
                }
            } else {
                RemoteAssetImage(name: "skin_pyro_feral_default")
                    .scaledToFit()
                    .padding(18)
                    .opacity(0.28)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }

    private var collection: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(teamManager.ownedCharacters) { owned in
                characterCard(owned)
            }
        }
    }

    private func characterCard(_ owned: OwnedCharacter) -> some View {
        let inTeam = teamManager.isInTeam(owned)
        let tint = inTeam ? gold : blue

        return VStack(spacing: 10) {
            Button {
                selectedCharacter = owned
            } label: {
                VStack(spacing: 9) {
                    RemoteAssetImage(
                        name: SkinInventoryManager.shared.activeImage(
                            for: owned.base
                        )
                    )
                    .scaledToFit()
                    .frame(height: 102)

                    Text(owned.base.name.uppercased())
                        .font(
                            .system(
                                size: 12,
                                weight: .black,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    HStack(spacing: 6) {
                        Text("LV \(owned.level)")
                        RemoteAssetImage(
                            name: MontamElement.parse(owned.base.energyType)
                                .icon
                        )
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        Text(MontamElement.parse(owned.base.energyType).title)
                    }
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(mutedText)

                    MontamStarRow(stars: owned.stars, size: 13)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Button("DETAIL") {
                    selectedCharacter = owned
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(black.opacity(0.7))
                .clipShape(TeamBladeRectangle(cut: 8))
                .overlay(
                    TeamBladeRectangle(cut: 8)
                        .stroke(tint.opacity(0.9), lineWidth: 1)
                )

                Button(inTeam ? "REMOVE" : "ADD") {
                    if inTeam {
                        if teamManager.activeTeam.count <= 1 {
                            showTeamWarning = true
                        } else {
                            teamManager.removeFromTeam(owned)
                        }
                    } else {
                        teamManager.addToTeam(owned)
                    }
                }
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(inTeam ? black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(inTeam ? gold : blue)
                .clipShape(TeamBladeRectangle(cut: 8))
            }
        }
        .padding(12)
        .background(panel)
        .overlay(TeamBladeRectangle(cut: 16).stroke(tint, lineWidth: 1.6))
        .clipShape(TeamBladeRectangle(cut: 16))
    }
}

private struct TeamBladeRectangle: Shape {
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
    TeamView(teamManager: TeamManager())
        .environmentObject(AppModel())
}
