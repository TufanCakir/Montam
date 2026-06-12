//
//  SummonView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct SummonView: View {
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var teamManager: TeamManager
    @ObservedObject var summonManager = SummonManager.shared

    @State private var selectedBanner: SummonBanner?
    @State private var pendingBanner: SummonBanner?
    @State private var pendingAmount = 1
    @State private var showSummonConfirm = false
    @State private var showNotEnoughCurrency = false
    @State private var missingCurrencyTitle = "Currency"
    @State private var summonResults: [Character] = []
    @State private var showResults = false
    @State private var selectedCategory = "standard"
    @State private var tutorialSummonUsed = UserDefaults.standard.bool(
        forKey: "tutorial_summon_done"
    )

    var isTutorial: Bool = false

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    var body: some View {
        VStack(spacing: 10) {
            categoryBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(summonManager.banners(for: selectedCategory)) {
                        banner in
                        bannerCard(banner)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
            }
        }
        .padding(.top, 8)
        .fullScreenCover(isPresented: $showResults) {
            SummonResultView(characters: summonResults)
        }
        .sheet(item: $selectedBanner) { banner in
            SummonPoolView(
                banner: banner,
                rates: summonManager.rates(for: banner.id)
            )
        }
        .alert(
            "Nicht genug \(missingCurrencyTitle)",
            isPresented: $showNotEnoughCurrency
        ) {
            Button("OK", role: .cancel) {}
        }
        .alert("Summon bestätigen", isPresented: $showSummonConfirm) {
            Button("Abbrechen", role: .cancel) {}
            Button("Bestätigen") {
                if let pendingBanner {
                    performSummon(for: pendingBanner, amount: pendingAmount)
                }
            }
        } message: {
            Text("Ziehe \(pendingAmount)x aus diesem Banner?")
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(summonManager.categories) { category in
                    categoryButton(category)
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private func categoryButton(_ category: SummonCategory) -> some View {
        let selected = selectedCategory == category.id

        return Button {
            selectedCategory = category.id
        } label: {
            Text(category.title.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(selected ? black : .white)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(selected ? gold : panel)
                .overlay(
                    SummonBladeRectangle(cut: 8).stroke(
                        selected ? blue : gold.opacity(0.55),
                        lineWidth: 1.4
                    )
                )
                .clipShape(SummonBladeRectangle(cut: 8))
        }
        .buttonStyle(.plain)
    }

    private func bannerCard(_ banner: SummonBanner) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                RemoteAssetImage(name: banner.bannerImage)
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 188)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            colors: [
                                black.opacity(0.15),
                                black.opacity(0.18),
                                black.opacity(0.90),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 7) {
                        tag("FEATURED")

                        if let pity = banner.pity, pity.enabled {
                            tag(
                                "PITY \(PityManager.shared.pulls(for: banner.id))/\(pity.requiredPulls)"
                            )
                        }

                        Spacer()

                        infoButton(for: banner)
                    }

                    Spacer()

                    Text(banner.title.uppercased())
                        .font(
                            .system(size: 21, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)
                        .shadow(color: .black.opacity(0.9), radius: 4, y: 2)

                    currencyTag(banner.currency)
                }
                .padding(12)
            }

            HStack(spacing: 8) {
                ForEach(currentOptions(for: banner)) { option in
                    summonButton(option: option, banner: banner)
                }
            }
            .padding(10)
            .background(black.opacity(0.86))
        }
        .background(panel)
        .opacity(summonManager.canSummon(banner) ? 1 : 0.42)
        .overlay(SummonBladeRectangle(cut: 18).stroke(gold, lineWidth: 1.8))
        .clipShape(SummonBladeRectangle(cut: 18))
        .disabled(!summonManager.canSummon(banner))
    }

    private func tag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black, design: .rounded))
            .foregroundStyle(black)
            .padding(.horizontal, 8)
            .frame(height: 22)
            .background(gold)
            .clipShape(SummonBladeRectangle(cut: 6))
    }

    private func currencyTag(_ currency: String) -> some View {
        HStack(spacing: 5) {
            RemoteAssetImage(name: currencyInfo(for: currency).icon)
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text(currencyInfo(for: currency).title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(black)
        }
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(gold)
        .clipShape(SummonBladeRectangle(cut: 6))
    }

    private func infoButton(for banner: SummonBanner) -> some View {
        Button {
            selectedBanner = banner
        } label: {
            HStack(spacing: 7) {
                RemoteAssetImage(name: "icon_info")
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 8)
            .frame(height: 28)
            .background(black)
            .clipShape(SummonBladeShape(pointDepth: 10, slant: 6))
            .overlay(
                SummonBladeShape(pointDepth: 10, slant: 6)
                    .stroke(gold.opacity(0.85), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func currentOptions(for banner: SummonBanner) -> [SummonOption] {
        summonManager.currentStepData(for: banner)?.costs ?? banner.summons
    }

    private func summonButton(option: SummonOption, banner: SummonBanner)
        -> some View
    {
        Button {
            guard !isTutorial || !tutorialSummonUsed else { return }
            pendingBanner = banner
            pendingAmount = option.amount
            showSummonConfirm = true
        } label: {
            HStack(spacing: 6) {
                RemoteAssetImage(name: currencyInfo(for: banner.currency).icon)
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(isTutorial ? "FREE" : "\(option.amount)x / \(option.cost)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(gold)
            .overlay(
                SummonBladeShape(pointDepth: 18, slant: 10).stroke(
                    blue,
                    lineWidth: 1.4
                )
            )
            .clipShape(SummonBladeShape(pointDepth: 18, slant: 10))
        }
        .buttonStyle(.plain)
    }

    private func performSummon(for banner: SummonBanner, amount: Int) {
        let options = currentOptions(for: banner)
        guard let option = options.first(where: { $0.amount == amount }) else {
            return
        }
        guard summonManager.canSummon(banner) else { return }

        if !isTutorial {
            guard spendCurrency(banner.currency, amount: option.cost) else {
                missingCurrencyTitle = currencyInfo(for: banner.currency).title
                showNotEnoughCurrency = true
                return
            }
        }

        summonResults.removeAll()
        for _ in 0..<amount {
            if let character = summonManager.smartSummon(from: banner) {
                teamManager.addOwnedCharacter(OwnedCharacter(base: character))
                summonResults.append(character)
            }
        }

        summonManager.addPull(for: banner.id, amount: amount)
        showResults = true

        if isTutorial {
            tutorialSummonUsed = true
            UserDefaults.standard.set(true, forKey: "tutorial_summon_done")
            appModel.tutorialState = .done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
        }
    }

    private func spendCurrency(_ currency: String, amount: Int) -> Bool {
        switch currency.lowercased() {
        case "montamcoins":
            return MontamCoinsManager.shared.spend(amount)
        case "montamsaphirs":
            return MontamSaphirsManager.shared.spend(amount)
        case "montamshards":
            return MontamShardsManager.shared.spend(amount)
        case "montamrubys":
            return MontamRubysManager.shared.spend(amount)
        case "montamliquid":
            return MontamLiquidManager.shared.spend(amount)
        case "montamcontainers":
            return MontamContainersManager.shared.spend(amount)
        default:
            return false
        }
    }

    private func currencyInfo(for currency: String) -> (
        title: String, icon: String
    ) {
        switch currency.lowercased() {
        case "montamcoins":
            return ("montamCoins", "icon_montam_coins")
        case "montamsaphirs":
            return ("montamSaphirs", "icon_montam_saphir")
        case "montamshards":
            return ("montamShards", "icon_montam_shards")
        case "montamrubys":
            return ("montamRubys", "icon_montam_rubys")
        case "montamliquid":
            return ("montamLiquid", "icon_montam_liquid")
        case "montamcontainers":
            return ("montamContainers", "icon_montam_containers")
        default:
            return (currency.uppercased(), "montam_icon")
        }
    }
}

private struct SummonBladeShape: Shape {
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

private struct SummonBladeRectangle: Shape {
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
    SummonView(teamManager: TeamManager())
        .environmentObject(AppModel())
}
