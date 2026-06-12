//
//  ShopView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import StoreKit
import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var storeProducts: [StoreProduct] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCategory = "real_money"

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    private var categories: [ShopCategory] {
        Array(
            Dictionary(
                grouping: storeProducts.map { $0.shopItem.category },
                by: { $0.id }
            ).values.compactMap { $0.first }
        )
    }

    private var filteredProducts: [StoreProduct] {
        storeProducts.filter {
            selectedCategory.isEmpty
                || $0.shopItem.category.id == selectedCategory
        }
    }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        VStack(spacing: 14) {
            categoryBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if isLoading {
                        stateView(title: "SHOP LADEN", image: "montam_icon")
                    } else if let errorMessage {
                        stateView(
                            title: errorMessage,
                            image: "skin_imperion_exalted_default"
                        )
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(filteredProducts, id: \.id) { product in
                                productCard(product)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(.top, 18)
        .background {
            MontamBackground()
        }
        .task { await loadShop() }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    let selected = selectedCategory == category.id
                    let title = category.id.replacingOccurrences(
                        of: "_",
                        with: " "
                    ).uppercased()

                    Button {
                        selectedCategory = category.id
                    } label: {
                        Text(title)
                            .font(
                                .system(
                                    size: 12,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(selected ? black : .white)
                            .padding(.horizontal, 18)
                            .frame(height: 38)
                            .background(selected ? gold : panel)
                            .overlay(
                                ShopBladeRectangle(cut: 10)
                                    .stroke(
                                        selected ? blue : gold.opacity(0.55),
                                        lineWidth: 1.4
                                    )
                            )
                            .clipShape(ShopBladeRectangle(cut: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func productCard(_ storeProduct: StoreProduct) -> some View {
        let item = storeProduct.shopItem
        let price =
            storeProduct.product?.displayPrice
            ?? (item.storeProductId == nil ? "FREE" : "NICHT VERFUEGBAR")
        let hasValidProduct =
            item.storeProductId == nil || storeProduct.product != nil
        let canBuy = hasValidProduct && ShopManager.canPurchase(item)

        return VStack(spacing: 12) {
            RemoteAssetImage(name: item.rewardIcon)
                .scaledToFit()
                .frame(height: 92)

            Text(
                item.tag?.uppercased()
                    ?? item.category.id.replacingOccurrences(of: "_", with: " ")
                    .uppercased()
            )
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(gold)
            .lineLimit(1)

            if let limitText = purchaseLimitText(for: item) {
                Text(limitText)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(mutedText)
                    .lineLimit(1)
            }

            rewardList(for: item)

            Button {
                Task { await purchase(storeProduct) }
            } label: {
                Text((canBuy ? price : "LIMIT ERREICHT").uppercased())
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(blue)
                    .overlay(
                        ShopBladeShape(pointDepth: 16, slant: 9).stroke(
                            gold,
                            lineWidth: 1.4
                        )
                    )
                    .clipShape(ShopBladeShape(pointDepth: 16, slant: 9))
            }
            .buttonStyle(.plain)
            .disabled(!canBuy)
            .opacity(canBuy ? 1 : 0.55)
        }
        .padding(14)
        .background(panel)
        .overlay(ShopBladeRectangle(cut: 16).stroke(gold, lineWidth: 1.6))
        .clipShape(ShopBladeRectangle(cut: 16))
    }

    private func stateView(title: String, image: String) -> some View {
        VStack(spacing: 12) {
            RemoteAssetImage(name: image)
                .scaledToFit()
                .frame(width: 84, height: 84)

            Text(title.uppercased())
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func rewardList(for item: ShopItem) -> some View {
        VStack(spacing: 6) {
            ForEach(item.rewardLines.prefix(3), id: \.self) { reward in
                HStack(spacing: 7) {
                    RemoteAssetImage(name: reward.icon)
                        .scaledToFit()
                        .frame(width: 22, height: 22)

                    Text("+\(reward.amount) \(reward.title)")
                        .font(
                            .system(size: 13, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer(minLength: 0)
                }
            }

            if item.rewardLines.count > 3 {
                Text("+\(item.rewardLines.count - 3) MEHR")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(gold)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 46, alignment: .topLeading)
    }

    private func loadShop() async {
        do {
            let shopItems: [ShopItem] = try JSONLoader.load("shop")
            let ids = shopItems.compactMap { $0.storeProductId }
            try await StoreKitService.shared.loadProducts(ids: ids)
            storeProducts = ShopManager().buildStoreProducts(
                shopItems: shopItems
            )
            selectedCategory = categories.first?.id ?? selectedCategory
            isLoading = false
        } catch {
            errorMessage = "Shop konnte nicht geladen werden"
            isLoading = false
        }
    }

    private func purchase(_ storeProduct: StoreProduct) async {
        let item = storeProduct.shopItem
        guard ShopManager.canPurchase(item) else { return }

        if storeProduct.product == nil {
            guard item.storeProductId == nil else { return }
            grantItem(item)
            return
        }

        guard let product = storeProduct.product else { return }

        do {
            if try await StoreKitService.shared.purchase(product) {
                grantItem(item)
            }
        } catch {
            print("Purchase error:", error)
        }
    }

    private func grantItem(_ item: ShopItem) {
        if let montamCoins = item.montamCoins {
            MontamCoinsManager.shared.add(montamCoins)
        }
        if let montamSaphirs = item.montamSaphirs {
            MontamSaphirsManager.shared.add(montamSaphirs)
        }
        if let montamRubys = item.montamRubys {
            MontamRubysManager.shared.add(montamRubys)
        }
        if let montamLiquid = item.montamLiquid {
            MontamLiquidManager.shared.add(montamLiquid)
        }
        if let montamShards = item.montamShards {
            MontamShardsManager.shared.add(montamShards)
        }
        if let exp = item.exp { PlayerProgressManager.shared.addEXP(exp) }
        if let montamContainers = item.montamContainers {
            MontamContainersManager.shared.add(montamContainers)
        }
        if let eggId = item.eggId {
            EggInventoryManager.shared.add(max(1, item.eggs ?? 1), eggId: eggId)
        }
        if let skinId = item.skinId {
            SkinInventoryManager.shared.unlock(skinId)
        }
        if let characterId = item.characterId {
            RewardApplier.apply(
                type: .montam,
                amount: 1,
                characterId: characterId,
                eggId: nil,
                skinId: nil,
                teamManager: appModel.teamManager
            )
        }
        if let medalId = item.medalId {
            MontamMedalManager.shared.add(
                max(1, item.medals ?? 1),
                medalId: medalId
            )
        }

        if item.oneTimePurchase == true {
            ShopManager.recordPurchase(item)
            storeProducts.removeAll { $0.shopItem.id == item.id }
            return
        }

        ShopManager.recordPurchase(item)
        if !ShopManager.canPurchase(item) {
            storeProducts.removeAll { $0.shopItem.id == item.id }
        }
    }

    private func purchaseLimitText(for item: ShopItem) -> String? {
        guard let limit = ShopManager.effectiveLimit(for: item),
            let remaining = ShopManager.remainingPurchases(for: item)
        else {
            return nil
        }

        return "\(remaining)/\(limit) verfuegbar"
    }
}

private struct ShopBladeShape: Shape {
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

private struct ShopBladeRectangle: Shape {
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
    ShopView()
        .environmentObject(AppModel())
}
