//
//  SummonComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

enum SummonLayoutMetrics {
    static let screenPadding: CGFloat = 22
    static let topPadding: CGFloat = 22
    static let bottomPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 18

    static let walletHeight: CGFloat = 30
    static let categoryWidth: CGFloat = 146
    static let categoryHeight: CGFloat = 64
    static let focusMinHeight: CGFloat = 300
    static let focusMaxHeight: CGFloat = 380
    static let actionHeight: CGFloat = 58
    static let bannerSpacing: CGFloat = 100
    static let cornerRadius: CGFloat = 8
}

struct SummonHeader: View {
    let ticketCount: Int
    let crystalCount: Int

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 10) {
                SummonWalletPill(
                    iconId: "summon_ticket",
                    fallbackImage: "icon_summon_ticket",
                    value: ticketCount
                )

                SummonWalletPill(
                    iconId: "crystal",
                    fallbackImage: "icon_crystal",
                    value: crystalCount
                )
            }
        }
    }
}

private struct SummonWalletPill: View {
    let iconId: String
    let fallbackImage: String
    let value: Int

    var body: some View {
        HStack(spacing: 7) {
            GameResourceIcon(id: iconId, fallbackImage: fallbackImage)
                .frame(width: 22, height: 22)

            Text(GameNumberFormatter.compact(value))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 10)
        .frame(height: SummonLayoutMetrics.walletHeight)
        .background(Color.blue.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(.white.opacity(0.45), lineWidth: 1)
        )
    }
}

struct SummonCategoryPicker: View {
    let categories: [SummonCategoryData]
    let summons: [SummonData]
    @Binding var selectedCategoryId: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        SummonCategoryTile(
                            title: category.title,
                            summon: previewSummon(for: category),
                            isSelected: selectedCategoryId == category.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private func previewSummon(for category: SummonCategoryData) -> SummonData?
    {
        summons.first { $0.category == category.id }
    }
}

private struct SummonCategoryTile: View {
    let title: String
    let summon: SummonData?
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            if let summon {
                SummonCategoryArtwork(summon: summon)
                    .frame(width: 34, height: 34)
            }

            Text(title)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(isSelected ? .white : .blue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .frame(
            width: SummonLayoutMetrics.categoryWidth,
            height: SummonLayoutMetrics.categoryHeight
        )
        .background(isSelected ? Color.blue : Color.white.opacity(0.80))
        .clipShape(
            RoundedRectangle(cornerRadius: SummonLayoutMetrics.cornerRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SummonLayoutMetrics.cornerRadius)
                .stroke(.blue.opacity(isSelected ? 0.75 : 0.45), lineWidth: 1)
        )
    }
}

private struct SummonCategoryArtwork: View {
    let summon: SummonData

    var body: some View {
        RemoteAssetImage(imageName: summon.bannerImage)
            .scaledToFit()
    }
}

struct SummonCategoryPage: View {
    let summons: [SummonData]
    let rates: (SummonData) -> [SummonRateData]
    let onShowRates: (SummonData, [SummonRateData]) -> Void
    let onSummon: (SummonData, Int) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: SummonLayoutMetrics.bannerSpacing) {
                ForEach(summons, id: \.id) { summon in
                    SummonBannerSection(
                        summon: summon,
                        rates: rates(summon),
                        onShowRates: onShowRates,
                        onSummon: onSummon
                    )
                }
            }
        }
    }
}

private struct SummonBannerSection: View {
    let summon: SummonData
    let rates: [SummonRateData]
    let onShowRates: (SummonData, [SummonRateData]) -> Void
    let onSummon: (SummonData, Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            SummonFocusView(
                summon: summon,
                onShowRates: {
                    onShowRates(summon, rates)
                }
            )
            SummonActionRow(summon: summon, onSummon: onSummon)
        }
        .padding(.bottom, 68)
    }
}

struct SummonFocusView: View {
    let summon: SummonData
    let onShowRates: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 5) {
                Text(summon.title)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Button(action: onShowRates) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)

            ZStack {

                SummonArtwork(summon: summon)
                    .padding(.horizontal, 52)
                    .padding(.vertical, 16)
            }
            .frame(maxWidth: .infinity)
            .frame(
                minHeight: SummonLayoutMetrics.focusMinHeight,
                maxHeight: SummonLayoutMetrics.focusMaxHeight
            )
        }
    }
}

struct SummonRateInfo: Identifiable {
    let id = UUID()
    let title: String
    let rates: [SummonRateData]
}

struct SummonRateInfoSheet: View {
    let info: SummonRateInfo

    private var totalWeight: Int {
        max(info.rates.reduce(0) { $0 + max($1.weight, 0) }, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(info.title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text("Summon Rates")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)

            VStack(spacing: 8) {
                ForEach(info.rates) { rate in
                    SummonRateRow(rate: rate, totalWeight: totalWeight)
                }
            }

            Text(
                "10x garantiert mindestens Rare. Legendär bleibt absichtlich sehr selten."
            )
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.72))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(Color(red: 0.02, green: 0.08, blue: 0.20))
    }
}

private struct SummonRateRow: View {
    let rate: SummonRateData
    let totalWeight: Int

    private var percent: Double {
        Double(max(rate.weight, 0)) / Double(max(totalWeight, 1)) * 100
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(rate.title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Text(percentText)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .frame(height: 38)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var percentText: String {
        if percent < 1 {
            return String(format: "%.2f%%", percent)
        }
        return String(format: "%.1f%%", percent)
    }

    private var color: Color {
        switch rate.rarity.lowercased() {
        case "legendary", "legendär", "ur", "lr":
            return .orange
        case "epic", "ssr":
            return .purple
        case "rare", "r", "sr":
            return .blue
        default:
            return .green
        }
    }
}

private struct SummonArtwork: View {
    let summon: SummonData

    var body: some View {
        RemoteAssetImage(imageName: summon.bannerImage)
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SummonActionRow: View {
    let summon: SummonData
    let onSummon: (SummonData, Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            SummonActionButton(
                count: 1,
                cost: summon.singleCost,
                currency: summon.currency,
                style: .primary
            ) {
                onSummon(summon, 1)
            }

            SummonActionButton(
                count: 10,
                cost: summon.multiCost,
                currency: summon.currency,
                style: .highlight
            ) {
                onSummon(summon, 10)
            }
        }
    }
}

struct SummonActionButton: View {
    enum Style {
        case primary
        case highlight
    }

    let count: Int
    let cost: Int
    let currency: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    GameResourceIcon(id: currency, fallbackImage: nil)
                        .frame(width: 20, height: 20)
                    Text("\(cost)")
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                }

                Text(count == 1 ? "1x beschwören" : "10x beschwören")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: SummonLayoutMetrics.actionHeight)
            .background(backgroundColor)
            .clipShape(
                RoundedRectangle(cornerRadius: SummonLayoutMetrics.cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SummonLayoutMetrics.cornerRadius)
                    .stroke(.black.opacity(0.58), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        style == .highlight ? .yellow : .blue
    }

    private var foregroundColor: Color {
        style == .highlight ? .brown : .white
    }
}

struct SummonEmptyState: View {
    var body: some View {
        Text("Keine Beschwörung in dieser Kategorie")
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(.blue)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
    }
}

struct SummonToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.74))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 36)
    }
}

struct SummonSideChevron: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(.blue.opacity(0.82))
                .frame(width: 42, height: 72)
        }
        .buttonStyle(.plain)
    }
}

struct SummonScreenBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

struct SparkView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 14, height: 74)
            Rectangle()
                .frame(width: 74, height: 14)
            Circle()
                .frame(width: 24, height: 24)
        }
    }
}

