import SwiftData
import SwiftUI

//  ShopComponents.swift
//  Monster Transorfmieren

enum ShopSection: CaseIterable, Identifiable {
    case pass
    case premiumCurrency
    case item
    case normal

    var id: Self { self }

    var title: String {
        switch self {
        case .pass: "Pass"
        case .premiumCurrency: "Premium-Währung"
        case .item: "Item"
        case .normal: "Normaler Shop"
        }
    }

    var jsonKey: String {
        switch self {
        case .pass: "pass"
        case .premiumCurrency: "premiumCurrency"
        case .item: "item"
        case .normal: "normal"
        }
    }
}

private enum ShopProductVisual {
    case diamonds
    case emeralds
    case tickets
    case farm
    case pass(Color)
    case normal(String, Color)
}

struct ShopBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

struct ShopTitleBar: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 27, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(colors: [.cyan, .cyan.opacity(0.4), .cyan], startPoint: .leading, endPoint: .trailing)
            )
    }
}

struct ShopWalletFilterBar: View {
    @Query private var saves: [GameSaveData]
    @Binding var selectedSection: ShopSection

    var body: some View {
        HStack {
            ShopWalletValue(image: "icon_crystal", text: formatNumber(saves.first?.crystals ?? 0))
            ShopWalletValue(image: "icon_coin", text: formatNumber(saves.first?.coins ?? 0))

            Spacer()

            Menu {
                ForEach(ShopSection.allCases) { section in
                    Button(section.title) {
                        selectedSection = section
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Text(selectedSection.title)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
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
        }
        .padding(.horizontal, 36)
        .frame(height: 54)
        .background(Color.blue.opacity(0.45))
    }

    private func formatNumber(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1f M", Double(value) / 1_000_000)
        }

        if value >= 1_000 {
            return String(format: "%.1f K", Double(value) / 1_000)
        }

        return "\(value)"
    }
}

struct ShopSideCategories: View {
    let section: ShopSection
    let hasProducts: Bool

    private var entries: [(String, String)] {
        guard hasProducts else {
            return []
        }

        return switch section {
        case .pass:
            [("Pass", "star.circle")]
        case .premiumCurrency:
            [("Kristall", "seal")]
        case .item:
            [("Item", "calendar.badge.clock")]
        case .normal:
            [("Shop", "storefront")]
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                VStack(spacing: 10) {
                    Image(systemName: entry.1)
                        .font(.system(size: 24, weight: .heavy))
                    Text(entry.0)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(.white.opacity(index == 0 ? 1 : 0.82))
                .frame(width: 58, height: 118)
                .background(Color.blue.opacity(0.74))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.black.opacity(0.28), lineWidth: 1))
            }
        }
        .frame(width: entries.isEmpty ? 0 : 58)
    }
}

struct ShopProductGridContent: View {
    let products: [ShopProductData]
    let emptyTitle: String
    @ObservedObject var store: StoreKitShopManager
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        if products.isEmpty {
            ShopEmptyContent(title: emptyTitle)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 112, maximum: 164), spacing: 12)], spacing: 14) {
                ForEach(products) { product in
                    ShopProductCard(
                        product: product,
                        price: store.localizedPrice(for: product),
                        soldOut: store.isPurchased(product),
                        onBuy: onBuy
                    )
                    .frame(maxWidth: 164)
                }
            }
        }
    }
}

struct ShopPassContent: View {
    let products: [ShopProductData]
    @ObservedObject var store: StoreKitShopManager
    let onBuy: (ShopProductData) -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            if products.isEmpty {
                ShopEmptyContent(title: "Keine Pass-Produkte")
            } else {
                ForEach(products) { product in
                    ShopPassCard(
                        product: product,
                        price: store.localizedPrice(for: product),
                        purchased: store.isPurchased(product),
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
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.cyan.opacity(0.8), lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ShopProductCard: View {
    let product: ShopProductData
    let price: String
    let soldOut: Bool
    let onBuy: (ShopProductData) -> Void

    var body: some View {
        Button {
            guard !soldOut else {
                return
            }

            onBuy(product)
        } label: {
            ZStack {
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(colors: [.blue.opacity(0.72), .cyan.opacity(0.72)], startPoint: .top, endPoint: .bottom)
                        .overlay(ShopCardPattern().opacity(0.14))

                    ShopProductIcon(visual: productVisual(from: product))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if let badge = product.badge {
                        Text(badge)
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            .foregroundStyle(.blue)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.blue, lineWidth: 1))
                            .offset(x: 5, y: -8)
                    }

                    Text(product.subtitle ?? product.title)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)
                }
                .frame(height: 142)

                HStack(spacing: 8) {
                    Text(price)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .foregroundStyle(.black.opacity(0.78))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(.white.opacity(0.95))
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.cyan.opacity(0.8), lineWidth: 3))

            if soldOut {
                Color.black.opacity(0.58)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                Text("GEKAUFT")
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(Circle().stroke(.white.opacity(0.75), lineWidth: 3))
                    .rotationEffect(.degrees(-16))
            }
        }
        .frame(height: 180)
        }
        .buttonStyle(.plain)
    }

    private func productVisual(from product: ShopProductData) -> ShopProductVisual {
        switch product.visual {
        case "crystals":
            .diamonds
        case "coins":
            .emeralds
        case "pass":
            .pass(.purple)
        case "tickets":
            .tickets
        case "farm":
            .farm
        default:
            .normal("shippingbox.fill", .cyan)
        }
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
                        GameResourceIcon(id: "crystal", fallbackImage: "icon_crystal")
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(Double(index * 12 - 16)))
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
                        GameResourceIcon(id: "summon_ticket", fallbackImage: "icon_ticket")
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
            case .pass(let color):
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.gradient)
                    .frame(width: 120, height: 78)
                    .rotationEffect(.degrees(8))
                    .overlay(Image(systemName: "percent").font(.system(size: 38, weight: .heavy)).foregroundStyle(.white.opacity(0.85)))
            case .normal(let icon, let color):
                Image(systemName: icon)
                    .font(.system(size: 74, weight: .heavy))
                    .foregroundStyle(color)
                    .shadow(color: .white.opacity(0.85), radius: 2)
            }
        }
    }
}

private struct ShopPassCard: View {
    let product: ShopProductData
    let price: String
    let purchased: Bool
    let onBuy: (ShopProductData) -> Void

    private var color: Color {
        product.visual == "pass" ? .purple : .cyan
    }

    var body: some View {
        Button {
            guard !purchased else {
                return
            }

            onBuy(product)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 8) {
                        if let badge = product.badge {
                            Text(badge)
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.purple)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }

                        Text(product.purchaseType == .nonConsumable ? "EINMALIG" : "KAUFBAR")
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }

                    Text(product.title)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundStyle(color)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)

                    Text("✦ \(product.subtitle ?? product.title)")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
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
                .background(Color.indigo.opacity(0.34).overlay(ShopGridPattern().opacity(0.18)))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 0) {
                    ZStack {
                        LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                        ShopProductIcon(visual: .pass(color))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)

                    Text(purchased ? "GEKAUFT" : price)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(purchased ? .green : .red)
                            .frame(width: 112)
                            .frame(maxHeight: .infinity)
                            .background(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.cyan.opacity(0.85), lineWidth: 3))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
                        Text(section.title.replacingOccurrences(of: "-", with: "-\n").replacingOccurrences(of: " ", with: "\n"))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(selectedSection == section ? .white : .cyan)
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
    let text: String

    var body: some View {
        HStack(spacing: 7) {
            GameResourceIcon(id: visualId, fallbackImage: image)
                .frame(width: 31, height: 31)
            Text(text)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
            Text("+")
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(.cyan)
        }
    }

    private var visualId: String {
        switch image {
        case "icon_coin": "coin"
        case "icon_crystal": "crystal"
        case "icon_exp": "exp"
        default: "crystal"
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
