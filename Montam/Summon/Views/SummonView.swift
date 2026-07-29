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
    @State private var pendingSummon: PendingSummon?
    @AppStorage(AppLocalizationService.languageKey)
    private var languageRawValue = AppLanguage.german.rawValue

    var body: some View {
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
        .fullScreenCover(isPresented: $viewModel.isShowingSummonResult) {
            SummonResultView(
                title: viewModel.summonResultTitle,
                results: viewModel.summonResults
            ) {
                viewModel.isShowingSummonResult = false
            }
        }
        .overlay {
            ZStack {
                if pendingSummon != nil {
                    Color.black.opacity(0.62)
                        .ignoresSafeArea()
                        .onTapGesture {
                            pendingSummon = nil
                        }

                    GameConfirmationPopup(
                        title: AppLocalizationService.text(
                            "summon.confirmTitle"
                        ),
                        message: confirmMessage,
                        confirmTitle: confirmButtonTitle,
                        cancelTitle: AppLocalizationService.text(
                            "settings.cancel"
                        ),
                        icon: "sparkles",
                        onConfirm: confirmPendingSummon,
                        onCancel: {
                            pendingSummon = nil
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }

                if let message = viewModel.summonMessage {
                    SummonToast(message: message)
                }
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
        guard store.canSpend(currency: summon.currency, amount: cost) else {
            viewModel.showMessage(
                AppLocalizationService.text(
                    "summon.notEnoughCurrency",
                    viewModel.currencyName(summon.currency)
                )
            )
            return
        }

        pendingSummon = PendingSummon(summon: summon, count: count, cost: cost)
    }

    private func confirmPendingSummon() {
        guard let pendingSummon else {
            return
        }

        let didSpend = store.spendSummon(
            cost: pendingSummon.cost,
            currency: pendingSummon.summon.currency
        )

        guard didSpend else {
            viewModel.showMessage(
                AppLocalizationService.text(
                    "summon.notEnoughCurrency",
                    viewModel.currencyName(pendingSummon.summon.currency)
                )
            )
            self.pendingSummon = nil
            return
        }

        let results = viewModel.makeResults(
            for: pendingSummon.summon,
            count: pendingSummon.count
        )
        store.applySummonResults(
            results,
            monsters: viewModel.monsters,
            tamers: viewModel.tamers
        )

        viewModel.summonResults = results
        viewModel.summonResultTitle = pendingSummon.summon.title
        viewModel.isShowingSummonResult = true
        self.pendingSummon = nil
    }

    private var confirmButtonTitle: String {
        guard let pendingSummon else {
            return AppLocalizationService.text("summon.confirmButton")
        }

        return AppLocalizationService.text(
            "summon.confirmButtonCount",
            pendingSummon.count
        )
    }

    private var confirmMessage: String {
        guard let pendingSummon else {
            return ""
        }

        let currency = viewModel.currencyName(pendingSummon.summon.currency)
        return AppLocalizationService.text(
            "summon.confirmMessage",
            pendingSummon.summon.title,
            pendingSummon.cost,
            currency
        )
    }
}

private struct PendingSummon {
    let summon: SummonData
    let count: Int
    let cost: Int
}
