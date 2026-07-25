//
//  SummonView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct SummonView: View {
    let store: GameStore

    @State private var viewModel = SummonViewModel()
    @State private var selectedRateInfo: SummonRateInfo?

    var body: some View {
        ZStack {
            SummonScreenBackground()

            VStack(spacing: SummonLayoutMetrics.sectionSpacing) {
                SummonHeader(
                    ticketCount: store.summonTickets,
                    crystalCount: store.crystals
                )

                SummonCategoryPicker(
                    categories: viewModel.categories,
                    summons: viewModel.summons,
                    selectedCategoryId: $viewModel.selectedCategoryId
                )

                TabView(selection: $viewModel.selectedCategoryId) {
                    ForEach(viewModel.categories) { category in
                        SummonCategoryPage(
                            summons: viewModel.summons(for: category.id),
                            rates: { summon in viewModel.rates(for: summon) },
                            onShowRates: { summon, rates in
                                selectedRateInfo = SummonRateInfo(
                                    title: summon.title,
                                    rates: rates
                                )
                            },
                            onSummon: performSummon
                        )
                        .tag(category.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.horizontal, SummonLayoutMetrics.screenPadding)
            .padding(.top, SummonLayoutMetrics.topPadding)
            .padding(.bottom, SummonLayoutMetrics.bottomPadding)
        }
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
        .sheet(item: $selectedRateInfo) { info in
            SummonRateInfoSheet(info: info)
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.visible)
        }
        .padding(.top, 30)
    }

    private func performSummon(_ summon: SummonData, count: Int) {
        let cost = count == 10 ? summon.multiCost : summon.singleCost
        let didSpend = store.spendSummon(
            cost: cost,
            currency: summon.currency
        )

        guard didSpend else {
            viewModel.showMessage(
                "Nicht genug \(viewModel.currencyName(summon.currency))."
            )
            return
        }

        let results = viewModel.makeResults(for: summon, count: count)
        store.applySummonResults(
            results,
            monsters: viewModel.monsters,
            tamers: viewModel.tamers
        )

        viewModel.summonResults = results
        viewModel.summonResultTitle = summon.title
        viewModel.isShowingSummonResult = true
    }
}
