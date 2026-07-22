//
//  TeamView.swift
//  Monster Transorfmieren
//

import SwiftData
import SwiftUI

struct TeamView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]

    @State private var selectedSection = TeamSection.partner
    @State private var viewModel = TeamViewModel()

    var body: some View {
        VStack(spacing: 0) {
            TeamTitleBar(section: selectedSection)

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
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .partner:
            PartnerTeamContent(
                rows: viewModel.monsterRows(ownedMonsters: ownedMonsters),
                evolution: viewModel.availableEvolution(ownedMonsters: ownedMonsters),
                onSelect: selectMonster,
                onEvolve: evolveActiveMonster
            )
        case .support:
            SupportTeamContent(
                rows: viewModel.tamerRows(ownedTamers: ownedTamers),
                onSelect: selectTamer
            )
        case .kamerad:
            CompactTeamInfo(title: "Kamerad", message: "Vorbereitung läuft. Neue Kameraden erscheinen bald.")
        case .spSupport:
            CompactTeamInfo(title: "SP-Support", message: "Vorbereitung läuft. Neue Support-Optionen erscheinen bald.")
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
        TeamInventoryService.evolveActiveMonster(
            evolution,
            ownedMonsters: ownedMonsters,
            modelContext: modelContext
        )
    }
}

#Preview {
    TeamView()
}
