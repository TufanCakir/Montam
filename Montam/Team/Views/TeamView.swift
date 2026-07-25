//
//  TeamView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct TeamView: View {
    let store: GameStore

    @State private var selectedSection = TeamSection.partner
    @State private var viewModel = TeamViewModel()
    @State private var evolutionPreview: TeamEvolutionPreview?

    var body: some View {
        VStack(spacing: 0) {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    selectedContent
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }

            TeamSectionTabs(selectedSection: $selectedSection)
        }
        .background(TeamBackground())
        .overlay {
            if let evolutionPreview {
                TeamEvolutionPreviewOverlay(preview: evolutionPreview)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            store.syncJSONCompanions()
        }
        .padding(.top, 50)
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .partner:
            PartnerTeamContent(
                rows: viewModel.monsterRows(
                    ownedMonsters: store.ownedMonsters
                ),
                evolution: viewModel.availableEvolution(
                    ownedMonsters: store.ownedMonsters
                ),
                onSelect: selectMonster,
                onEquipAppearance: equipAppearance,
                onEvolve: evolveActiveMonster
            )
        case .support:
            SupportTeamContent(
                rows: viewModel.supporterRows(
                    ownedSupporters: store.ownedSupporters
                ),
                onSelect: selectSupporter
            )
        }
    }
    
    private func selectSupporter(_ id: String) {
        store.selectSupporter(id: id)
    }

    private func selectMonster(_ id: String) {
        store.selectMonster(id: id)
    }

    private func selectTamer(_ id: String) {
        store.selectTamer(id: id)
    }

    private func evolveActiveMonster(_ evolution: TeamEvolutionState) {
        let currentImageName =
            store.ownedMonsters.first(where: \.isSelected)?.equippedImageName
            ?? viewModel.activeMonsterImageName(
                ownedMonsters: store.ownedMonsters
            )
            ?? evolution.targetAppearance.imageName
        evolutionPreview = TeamEvolutionPreview(
            sourceImageName: currentImageName,
            targetImageName: evolution.targetAppearance.imageName,
            targetName: evolution.targetAppearance.title
        )

        if let activeMonsterId = store.ownedMonsters.first(where: \.isSelected)?
            .monsterId
        {
            store.transformActiveMonster(
                to: evolution.targetAppearance.imageName,
                monsterId: activeMonsterId
            )
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await MainActor.run {
                evolutionPreview = nil
            }
        }
    }

    private func equipAppearance(
        _ appearance: TeamAppearanceRow,
        monsterId: String
    ) {
        guard appearance.isUnlocked else {
            return
        }

        store.equipAppearance(
            imageName: appearance.imageName,
            monsterId: monsterId
        )
    }
}
