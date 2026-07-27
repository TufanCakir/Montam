//
//  ShopComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

enum ShopSection: CaseIterable, Identifiable {
    case pass
    case premiumCurrency
    case item

    var id: Self { self }

    var title: String {
        switch self {
        case .pass: "Pass"
        case .premiumCurrency: "Premium-Währung"
        case .item: "Item"
        }
    }

    var tabTitle: String {
        switch self {
        case .pass: "Pass"
        case .premiumCurrency: "Premium\nWährung"
        case .item: "Item"
        }
    }

    var jsonKey: String {
        switch self {
        case .pass: "pass"
        case .premiumCurrency: "premiumCurrency"
        case .item: "item"
        }
    }
}

private enum ShopProductVisual {
    case diamonds
    case bits
    case emeralds
    case tickets
    case farm
    case resource(String)
}

struct ShopWalletState {
    let coins: Int
    let crystals: Int
    let bits: Int
}

struct ShopWalletFilterBar: View {
    let wallet: ShopWalletState
    @Binding var selectedSection: ShopSection

    var body: some View {
        HStack(spacing: 14) {
            Menu {
                ForEach(ShopSection.allCases) { section in
                    Button(section.title) {
                        selectedSection = section
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Text(selectedSection.title)
                        .font(
                            .system(size: 20, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 31, height: 31)
                        .background(.blue)
                        .clipShape(Circle())
                }
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(Color.black.opacity(0.58))
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }

            Spacer(minLength: 10)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ShopWalletValue(image: "icon_coin", value: wallet.coins)
                    ShopWalletValue(
                        image: "icon_crystal",
                        value: wallet.crystals
                    )
                    ShopWalletValue(image: "icon_bit", value: wallet.bits)
                }

                HStack(spacing: 10) {
                    ShopWalletValue(
                        image: "icon_crystal",
                        value: wallet.crystals
                    )
                    ShopWalletValue(image: "icon_bit", value: wallet.bits)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 54)
        .background(Color.blue.opacity(0.45))
    }
}

struct ShopProductGridContent: View {
    let products: [ShopProductData]
    let emptyTitle: String
    @ObservedObject var store: StoreKitShopManager
    let priceTitle: (ShopProductData) -> String
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        if products.isEmpty {
            ShopEmptyContent(title: emptyTitle)
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 112, maximum: 164), spacing: 12)
                ],
                spacing: 14
            ) {
                ForEach(products) { product in
                    ShopProductCard(
                        product: product,
                        price: priceTitle(product),
                        soldOut: store.isPurchased(product),
                        storeUnavailable: store.isStoreKitUnavailable(product),
                        storeLoading: store.isLoadingProducts,
                        onBuy: onBuy
                    )
                    .frame(maxWidth: 164)
                }
            }
        }
    }
}

struct ItemShopContent: View {
    let products: [ItemShopProductData]
    let onBuy: (ItemShopProductData) -> Void

    var body: some View {
        if products.isEmpty {
            ShopEmptyContent(title: "Neue Items erscheinen bald.")
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 132, maximum: 190), spacing: 12)
                ],
                spacing: 14
            ) {
                ForEach(products) { product in
                    ItemShopProductCard(product: product, onBuy: onBuy)
                        .frame(maxWidth: 190)
                }
            }
        }
    }
}

struct ShopPassContent: View {
    let products: [ShopProductData]
    @ObservedObject var store: StoreKitShopManager
    let onBuy: (ShopProductData) -> Void
    let isPurchased: (ShopProductData) -> Bool
    let priceTitle: (ShopProductData) -> String
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            if products.isEmpty {
                ShopEmptyContent(title: "Keine Pass-Produkte")
            } else {
                ForEach(products) { product in
                    ShopPassCard(
                        product: product,
                        price: priceTitle(product),
                        purchased: isPurchased(product),
                        storeUnavailable: store.isStoreKitUnavailable(product),
                        storeLoading: store.isLoadingProducts,
                        onBuy: onBuy
                    )
                }
            }

            Button(action: onRestore) {
                Text("Käufe wiederherstellen")
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
    let product: ItemShopProductData
    let onBuy: (ItemShopProductData) -> Void

    var body: some View {
        Button {
            onBuy(product)
        } label: {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [.blue.opacity(0.7), .cyan.opacity(0.68)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .overlay(ShopCardPattern().opacity(0.14))

                    ShopProductIcon(visual: productVisual(from: product.visual))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if let badge = product.badge {
                        ShopBadge(title: badge, style: .light)
                            .padding(8)
                    }
                }
                .frame(height: 132)

                VStack(alignment: .leading, spacing: 7) {
                    Text(product.title)
                        .font(
                            .system(size: 18, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text(product.subtitle ?? rewardTitle)
                        .font(
                            .system(size: 13, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    HStack(spacing: 7) {
                        GameResourceIcon(
                            id: GameCurrency.iconId(for: product.priceCurrency),
                            fallbackImage:
                                "icon_\(GameCurrency.iconId(for: product.priceCurrency))"
                        )
                        .frame(width: 24, height: 24)

                        Text("\(product.priceAmount)")
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
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.indigo.opacity(0.4))
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.cyan.opacity(0.82), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var rewardTitle: String {
        if let tickets = product.rewards.summonTickets {
            return "+\(tickets) Tickets"
        }

        if let crystals = product.rewards.crystals {
            return "+\(crystals) Kristalle"
        }

        if let coins = product.rewards.coins {
            return "+\(coins) Coins"
        }

        if let bits = product.rewards.bits {
            return "+\(bits) Bits"
        }

        return "Item"
    }
}

private struct ShopProductCard: View {
    let product: ShopProductData
    let price: String
    let soldOut: Bool
    let storeUnavailable: Bool
    let storeLoading: Bool
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        Button {
            guard !soldOut && !storeUnavailable && !storeLoading else {
                return
            }

            onBuy(product)
        } label: {
            ZStack {
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        LinearGradient(
                            colors: [.blue.opacity(0.72), .cyan.opacity(0.72)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .overlay(ShopCardPattern().opacity(0.14))

                        ShopProductIcon(
                            visual: productVisual(from: product.visual)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        if let badge = product.badge {
                            ShopBadge(title: badge, style: .light)
                                .offset(x: 5, y: -8)
                        }

                        Text(product.subtitle ?? product.title)
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
                    .frame(height: 142)

                    HStack(spacing: 8) {
                        Text(price)
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
                    .frame(height: 38)
                    .background(.white.opacity(0.95))
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(
                        .cyan.opacity(0.8),
                        lineWidth: 3
                    )
                )

                if soldOut || storeUnavailable || storeLoading {
                    Color.black.opacity(0.58)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
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
            .frame(height: 180)
        }
        .buttonStyle(.plain)
        .disabled(soldOut || storeUnavailable || storeLoading)
    }

    private var cardOverlayTitle: String {
        if soldOut {
            return "GEKAUFT"
        }

        if storeLoading {
            return "LÄDT"
        }

        return "BALD"
    }
}

private func productVisual(from visual: String) -> ShopProductVisual {
    switch visual {
    case "crystals":
        .diamonds
    case "bits", "bit", "icon_bit":
        .bits
    case "coins":
        .emeralds
    case "tickets", "summon_ticket", "icon_summon_ticket":
        .tickets
    case "farm":
        .farm
    case "pass":
        .resource("pass")
    default:
        .resource(visual)
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
    let product: ShopProductData
    let price: String
    let purchased: Bool
    let storeUnavailable: Bool
    let storeLoading: Bool
    let onBuy: (ShopProductData) -> Void

    private var color: Color {
        product.visual == "pass" ? .purple : .cyan
    }

    var body: some View {
        Button {
            guard !purchased && !storeUnavailable && !storeLoading else {
                return
            }

            onBuy(product)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 8) {
                        if let badge = product.badge {
                            ShopBadge(title: badge, style: .accent(.purple))
                        }

                        ShopBadge(
                            title:
                                product.purchaseType == .nonConsumable
                                ? "EINMALIG" : "KAUFBAR",
                            style: .accent(.cyan)
                        )
                    }

                    Text(product.title)
                        .font(
                            .system(size: 22, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(color)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)

                    Text("✦ \(product.subtitle ?? product.title)")
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
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        ShopProductIcon(
                            visual: productVisual(from: product.visual)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)

                    Text(passPriceTitle)
                        .font(
                            .system(size: 22, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(
                            purchased
                                ? .green : storeUnavailable ? .gray : .black
                        )
                        .frame(width: 112)
                        .frame(maxHeight: .infinity)
                        .background(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(
                        .cyan.opacity(0.85),
                        lineWidth: 3
                    )
                )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(purchased || storeUnavailable || storeLoading)
    }

    private var passPriceTitle: String {
        if purchased {
            return "GEKAUFT"
        }

        if storeLoading {
            return "Lädt"
        }

        return price
    }

    private var rewardLines: [String] {
        var lines: [String] = []

        if product.rewards.unlockEventPass == true {
            lines.append(purchased ? "Freigeschaltet" : "Event-Zugang")
        }

        if let crystals = product.rewards.crystals {
            lines.append("+\(crystals) Kristalle")
        }

        if let coins = product.rewards.coins {
            lines.append("+\(coins) Coins")
        }

        return lines.isEmpty ? [product.subtitle ?? product.title] : lines
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
        .padding(.horizontal, 20)
        .background(
            Color(red: 0.02, green: 0.12, blue: 0.27)
                .overlay(alignment: .top) {
                    Rectangle().fill(.cyan.opacity(0.75)).frame(height: 2)
                }
        )
    }
}

private struct ShopWalletValue: View {
    let image: String
    let value: Int

    var body: some View {
        HStack(spacing: 7) {
            GameResourceIcon(id: visualId, fallbackImage: image)
                .frame(width: 25, height: 25)
            Text(GameNumberFormatter.compact(value))
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.72)
    }

    private var visualId: String {
        switch image {
        case "icon_coin": "coin"
        case "icon_crystal": "crystal"
        case "icon_bit": "bit"
        case "icon_exp": "exp"
        default: "crystal"
        }
    }
}

private struct ShopBadge: View {
    enum Style {
        case light
        case accent(Color)
    }

    let title: String
    let style: Style

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .heavy, design: .rounded))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                if case .light = style {
                    RoundedRectangle(cornerRadius: 4).stroke(
                        .blue.opacity(0.85),
                        lineWidth: 1
                    )
                }
            }
    }

    private var foregroundColor: Color {
        switch style {
        case .light: .blue
        case .accent: .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .light: .white.opacity(0.94)
        case .accent(let color): color
        }
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
