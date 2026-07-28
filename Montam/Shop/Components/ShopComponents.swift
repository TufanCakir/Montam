//
//  ShopComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

private enum ShopCardStyle {
    static let cornerRadius: CGFloat = 8
    static let compactCornerRadius: CGFloat = 6
    static let productImageHeight: CGFloat = 142
    static let itemImageHeight: CGFloat = 132
    static let passImageHeight: CGFloat = 150
    static let priceHeight: CGFloat = 38
    static let cardHeight: CGFloat = 180
    static let strokeWidth: CGFloat = 2
    static let strongStrokeWidth: CGFloat = 3
    static let gridSpacing: CGFloat = 12

    static let twoColumnGrid = [
        GridItem(.flexible(), spacing: gridSpacing),
        GridItem(.flexible(), spacing: gridSpacing),
    ]
}

struct ShopProductGridContent: View {
    let products: [ShopProductData]
    let emptyTitle: String
    let cardState: (ShopProductData) -> ShopStoreProductCardState
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        if products.isEmpty {
            ShopEmptyContent(title: emptyTitle)
        } else {
            LazyVGrid(
                columns: ShopCardStyle.twoColumnGrid,
                spacing: ShopCardStyle.gridSpacing
            ) {
                ForEach(products) { product in
                    ShopProductCard(
                        state: cardState(product),
                        onBuy: onBuy
                    )
                }
            }
        }
    }
}

struct ItemShopContent: View {
    let products: [ItemShopProductData]
    let emptyTitle: String
    let cardState: (ItemShopProductData) -> ShopItemProductCardState
    let onBuy: (ItemShopProductData) -> Void

    var body: some View {
        if products.isEmpty {
            ShopEmptyContent(title: emptyTitle)
        } else {
            LazyVGrid(
                columns: ShopCardStyle.twoColumnGrid,
                spacing: ShopCardStyle.gridSpacing
            ) {
                ForEach(products) { product in
                    ItemShopProductCard(
                        state: cardState(product),
                        onBuy: onBuy
                    )
                }
            }
        }
    }
}

struct ShopPassContent: View {
    let products: [ShopProductData]
    let cardState: (ShopProductData) -> ShopStoreProductCardState
    let onBuy: (ShopProductData) -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            if products.isEmpty {
                ShopEmptyContent(
                    title: AppLocalizationService.text("shop.empty.pass")
                )
            } else {
                ForEach(products) { product in
                    ShopPassCard(
                        state: cardState(product),
                        onBuy: onBuy
                    )
                }
            }

            Button(action: onRestore) {
                Text(AppLocalizationService.text("shop.restorePurchases"))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blue.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(
                            .cyan.opacity(0.8),
                            lineWidth: 2
                        )
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ItemShopProductCard: View {
    let state: ShopItemProductCardState
    let onBuy: (ItemShopProductData) -> Void

    var body: some View {
        Button {
            onBuy(state.product)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    ShopCardImageBackground()

                    ShopProductIcon(visual: state.visual)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: ShopCardStyle.itemImageHeight)

                VStack(alignment: .leading, spacing: 7) {
                    Text(state.title)
                        .font(
                            .system(size: 18, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text(state.subtitle)
                        .font(
                            .system(size: 13, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    HStack(spacing: 7) {
                        GameResourceIcon(
                            id: GameCurrency.iconId(for: state.priceCurrency),
                            fallbackImage:
                                "icon_\(GameCurrency.iconId(for: state.priceCurrency))"
                        )
                        .frame(width: 24, height: 24)

                        Text("\(state.priceAmount)")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Color.black.opacity(0.34))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: ShopCardStyle.compactCornerRadius
                        )
                    )
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.indigo.opacity(0.4))
            }
            .clipShape(
                RoundedRectangle(cornerRadius: ShopCardStyle.cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ShopCardStyle.cornerRadius)
                    .stroke(
                        .cyan.opacity(0.82),
                        lineWidth: ShopCardStyle.strokeWidth
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ShopProductCard: View {
    let state: ShopStoreProductCardState
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        Button {
            guard !isDisabled else {
                return
            }

            onBuy(state.product)
        } label: {
            ZStack {
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        ShopCardImageBackground()

                        ShopProductIcon(visual: state.visual)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Text(state.subtitle)
                            .font(
                                .system(
                                    size: 18,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                            .shadow(color: .black, radius: 1, x: 1, y: 1)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottom
                            )
                            .padding(.horizontal, 4)
                            .padding(.bottom, 8)
                    }
                    .frame(height: ShopCardStyle.productImageHeight)

                    HStack(spacing: 8) {
                        Text(state.price)
                            .font(
                                .system(
                                    size: 18,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.55)
                            .foregroundStyle(.black.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: ShopCardStyle.priceHeight)
                    .background(.white.opacity(0.95))
                }
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ShopCardStyle.compactCornerRadius
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: ShopCardStyle.compactCornerRadius
                    ).stroke(
                        .cyan.opacity(0.8),
                        lineWidth: ShopCardStyle.strongStrokeWidth
                    )
                )

                if isDisabled {
                    Color.black.opacity(0.58)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: ShopCardStyle.compactCornerRadius
                            )
                        )
                    Text(cardOverlayTitle)
                        .font(
                            .system(size: 25, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .background(
                            Circle().stroke(.white.opacity(0.75), lineWidth: 3)
                        )
                        .rotationEffect(.degrees(-16))
                }
            }
            .frame(height: ShopCardStyle.cardHeight)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var isDisabled: Bool {
        state.soldOut || state.storeUnavailable || state.storeLoading
    }

    private var cardOverlayTitle: String {
        if state.soldOut {
            return AppLocalizationService.text("shop.purchased")
        }

        if state.storeLoading {
            return AppLocalizationService.text("shop.loadingShort")
        }

        return AppLocalizationService.text("shop.soon")
    }
}

private struct ShopProductIcon: View {
    let visual: ShopProductVisual

    var body: some View {
        ZStack {
            switch visual {
            case .diamonds:
                HStack(spacing: -12) {
                    ForEach(0..<4, id: \.self) { index in
                        GameResourceIcon(
                            id: "crystal",
                            fallbackImage: "icon_crystal"
                        )
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(Double(index * 12 - 16)))
                        .offset(y: CGFloat(index % 2 * 12))
                    }
                }
            case .bits:
                HStack(spacing: -12) {
                    ForEach(0..<4, id: \.self) { index in
                        GameResourceIcon(id: "bit", fallbackImage: "icon_bit")
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(Double(index * 10 - 14)))
                            .offset(y: CGFloat(index % 2 * 12))
                    }
                }
            case .emeralds:
                HStack(spacing: -12) {
                    ForEach(0..<4, id: \.self) { index in
                        GameResourceIcon(id: "coin", fallbackImage: "icon_coin")
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(Double(index * 10 - 14)))
                            .offset(y: CGFloat(index % 2 * 12))
                    }
                }
            case .tickets:
                HStack(spacing: -16) {
                    ForEach(0..<4, id: \.self) { index in
                        GameResourceIcon(
                            id: "summon_ticket",
                            fallbackImage: "icon_summon_ticket"
                        )
                        .frame(width: 42, height: 72)
                        .rotationEffect(.degrees(Double(index * 7 - 10)))
                    }
                }
            case .farm:
                HStack(spacing: -8) {
                    Image(systemName: "bag.fill")
                    Image(systemName: "drop.fill")
                    Image(systemName: "leaf.fill")
                }
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(.green)
                .shadow(color: .white, radius: 2)
            case .resource(let id):
                GameResourceIcon(id: id, fallbackImage: id)
                    .scaledToFit()
                    .padding(12)
            }
        }
    }
}

private struct ShopPassCard: View {
    let state: ShopStoreProductCardState
    let onBuy: (ShopProductData) -> Void

    private var color: Color {
        if case .resource("pass") = state.visual {
            return .purple
        }

        return .cyan
    }

    var body: some View {
        Button {
            guard !isDisabled else {
                return
            }

            onBuy(state.product)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 9) {
                    Text(state.title)
                        .font(
                            .system(size: 22, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(color)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)

                    Text("✦ \(state.subtitle)")
                        .font(
                            .system(size: 13, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.black.opacity(0.45))

                    ForEach(rewardLines, id: \.self) { line in
                        SupplyRow(title: line, color: .green)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.indigo.opacity(0.34).overlay(
                        ShopGridPattern().opacity(0.18)
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 0) {
                    ZStack {
                        ShopCardImageBackground()
                        ShopProductIcon(visual: state.visual)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: ShopCardStyle.passImageHeight)

                    Text(passPriceTitle)
                        .font(
                            .system(size: 22, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(
                            state.soldOut
                                ? .green
                                : state.storeUnavailable ? .gray : .black
                        )
                        .frame(width: 112)
                        .frame(maxHeight: .infinity)
                        .background(.white)
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: ShopCardStyle.cornerRadius)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: ShopCardStyle.cornerRadius)
                        .stroke(
                            .cyan.opacity(0.85),
                            lineWidth: ShopCardStyle.strongStrokeWidth
                        )
                )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }

    private var isDisabled: Bool {
        state.soldOut || state.storeUnavailable || state.storeLoading
    }

    private var passPriceTitle: String {
        if state.soldOut {
            return AppLocalizationService.text("shop.purchased")
        }

        if state.storeLoading {
            return AppLocalizationService.text("shop.loadingShort")
        }

        return state.price
    }

    private var rewardLines: [String] {
        var lines: [String] = []

        if state.product.rewards.unlockEventPass == true {
            lines.append(
                state.soldOut
                    ? AppLocalizationService.text("shop.unlocked")
                    : AppLocalizationService.text("shop.montamPass")
            )
        }

        if let crystals = state.product.rewards.crystals {
            lines.append("+\(crystals) \(GameCurrency.title(for: "crystals"))")
        }

        if let coins = state.product.rewards.coins {
            lines.append("+\(coins) \(GameCurrency.title(for: "coins"))")
        }

        return lines.isEmpty ? [state.subtitle] : lines
    }
}

private struct ShopEmptyContent: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(Color.blue.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ShopCardImageBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.42, blue: 0.86),
                Color(red: 0.0, green: 0.72, blue: 0.82),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(ShopCardPattern().opacity(0.14))
    }
}

struct ShopToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 18, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 36)
    }
}

private struct SupplyRow: View {
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Text("✦ \(title)")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 27)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

struct ShopSectionTabs: View {
    @Binding var selectedSection: ShopSection

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ShopSection.allCases) { section in
                Button {
                    selectedSection = section
                } label: {
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(selectedSection == section ? .cyan : .clear)
                            .frame(width: 90, height: 7)
                        Text(section.tabTitle)
                            .font(
                                .system(
                                    size: 20,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selectedSection == section ? .white : .cyan
                            )
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity, minHeight: 62)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Color(red: 0.02, green: 0.12, blue: 0.27)
                .overlay(alignment: .top) {
                    Rectangle().fill(.cyan.opacity(0.75)).frame(height: 2)
                }
        )
    }
}

private struct ShopCardPattern: View {
    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 120, weight: .heavy))
            .foregroundStyle(.white.opacity(0.35))
    }
}

private struct ShopGridPattern: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<18, id: \.self) { _ in
                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(height: 1)
            }
        }
    }
}
