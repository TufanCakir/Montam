//
//  TeamView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct TeamView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]

    @State private var selectedSection = TeamSection.partner
    @State private var viewModel = TeamViewModel()
    @State private var evolutionPreview: TeamEvolutionPreview?

    var body: some View {
        VStack(spacing: 0) {
            if selectedSection != .partner {
                TeamTitleBar(section: selectedSection)
            }

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
            TeamInventoryService.syncJSONCompanions(
                ownedMonsters: ownedMonsters,
                ownedTamers: ownedTamers,
                modelContext: modelContext
            )
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .partner:
            PartnerTeamContent(
                rows: viewModel.monsterRows(ownedMonsters: ownedMonsters),
                evolution: viewModel.availableEvolution(
                    ownedMonsters: ownedMonsters
                ),
                onSelect: selectMonster,
                onEquipAppearance: equipAppearance,
                onEvolve: evolveActiveMonster
            )
        case .support:
            SupportTeamContent(
                rows: viewModel.tamerRows(ownedTamers: ownedTamers),
                onSelect: selectTamer
            )
        }
    }

    private func selectMonster(_ id: String) {
        TeamInventoryService.selectMonster(
            id: id,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }

    private func selectTamer(_ id: String) {
        TeamInventoryService.selectTamer(
            id: id,
            ownedTamers: ownedTamers,
            modelContext: modelContext
        )
    }

    private func evolveActiveMonster(_ evolution: EvolutionData) {
        let currentImageName =
            ownedMonsters.first(where: \.isSelected)?.equippedImageName
            ?? viewModel.activeMonsterImageName(ownedMonsters: ownedMonsters)
            ?? evolution.sourceMonsterId
        evolutionPreview = TeamEvolutionPreview(
            sourceImageName: currentImageName,
            targetImageName: evolution.targetImageName,
            targetName: evolution.displayName
        )

        TeamInventoryService.evolveActiveMonster(
            evolution,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )

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

        TeamInventoryService.equipAppearance(
            imageName: appearance.imageName,
            monsterId: monsterId,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }
}

#Preview {
    TeamView()
}
