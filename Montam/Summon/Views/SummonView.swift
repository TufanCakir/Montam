//
//  SummonView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftData
import SwiftUI

struct SummonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var saves: [GameSaveData]
    @Query private var ownedMonsters: [OwnedMonsterData]
    @Query private var ownedTamers: [OwnedTamerData]

    @State private var viewModel = SummonViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SummonTitleBar(
                ticketCount: saves.first?.summonTickets ?? 0,
                crystalCount: saves.first?.crystals ?? 0
            )

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    SummonCategoryPicker(
                        categories: viewModel.categories,
                        selectedCategoryId: $viewModel.selectedCategoryId
                    )

                    if viewModel.filteredSummons.isEmpty {
                        SummonEmptyState()
                    } else {
                        SummonBannerPageList(
                            summons: viewModel.filteredSummons,
                            onSummon: performSummon
                        )
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                .padding(.bottom, 12)
            }
            .overlay(alignment: .leading) {
                SummonSideChevron(systemName: "chevron.left") {
                    viewModel.moveCategory(by: -1)
                }
                .padding(.leading, 6)
            }
            .overlay(alignment: .trailing) {
                SummonSideChevron(systemName: "chevron.right") {
                    viewModel.moveCategory(by: 1)
                }
                .padding(.trailing, 6)
            }
        }
        .background(SummonGeneratedBackground())
        .fullScreenCover(isPresented: $viewModel.isShowingSummonResult) {
            SummonResultView(
                title: viewModel.summonResultTitle,
                results: viewModel.summonResults
            ) {
                viewModel.isShowingSummonResult = false
            }
        }
        .overlay {
            if let message = viewModel.summonMessage {
                SummonToast(message: message)
            }
        }
    }

    private func performSummon(_ summon: SummonData, count: Int) {
        let cost =
            count == 10 ? (summon.multiCost ?? 0) : (summon.singleCost ?? 0)
        let didSpend = SummonInventoryService.spend(
            cost: cost,
            currency: summon.currency,
            saves: saves,
            modelContext: modelContext
        )

        guard didSpend else {
            viewModel.showMessage(
                "Nicht genug \(viewModel.currencyName(summon.currency))."
            )
            return
        }

        let results = viewModel.makeResults(for: summon, count: count)
        SummonInventoryService.applyResults(
            results,
            monsters: viewModel.monsters,
            tamers: viewModel.tamers,
            ownedMonsters: ownedMonsters,
            ownedTamers: ownedTamers,
            modelContext: modelContext
        )

        viewModel.summonResults = results
        viewModel.summonResultTitle = summon.title
        viewModel.isShowingSummonResult = true
    }
}

#Preview {
    SummonView()
}
