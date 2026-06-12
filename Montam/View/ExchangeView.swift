//
//  ExchangeView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct ExchangeView: View {
    @StateObject private var exchange = ExchangeManager.shared
    @State private var showFail = false

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    var body: some View {
        VStack(spacing: 14) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(visibleOffers) { offer in
                        offerCard(offer)
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
        .alert("Nicht genug MontamCoins", isPresented: $showFail) {
            Button("OK", role: .cancel) {}
        }
    }

    private var visibleOffers: [ExchangeOffer] {
        exchange.offers.filter { $0.coinCost != nil && $0.gemReward != nil }
    }

    private func offerCard(_ offer: ExchangeOffer) -> some View {
        let cost = offer.coinCost ?? 0
        let reward = offer.gemReward ?? 0
        let remaining = exchange.remaining(offer)
        let tint = gold

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                RemoteAssetImage(name: "icon_montam_saphir")
                    .scaledToFit()
                    .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text(offer.title.uppercased())
                        .font(
                            .system(size: 16, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Text("LIMIT \(remaining) / \(offer.purchaseLimit)")
                        .font(
                            .system(size: 11, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(mutedText)
                }

                Spacer()
            }

            HStack(spacing: 12) {
                tradePill(
                    image: "icon_montam_coins",
                    text: "-\(cost)",
                    tint: tint
                )
                tradePill(
                    image: "icon_montam_saphir",
                    text: "+\(reward)",
                    tint: tint
                )
            }

            Button {
                if !exchange.buy(offer: offer) {
                    showFail = true
                }
            } label: {
                Text(remaining == 0 ? "SOLD OUT" : "EXCHANGE")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        remaining == 0 ? Color.gray.opacity(0.35) : tint
                    )
                    .clipShape(ExchangeBladeShape(pointDepth: 18, slant: 10))
            }
            .buttonStyle(.plain)
            .disabled(remaining == 0 || cost == 0 || reward == 0)
        }
        .padding(16)
        .background(panel)
        .opacity(remaining == 0 ? 0.45 : 1)
        .overlay(ExchangeBladeRectangle(cut: 18).stroke(tint, lineWidth: 1.7))
        .clipShape(ExchangeBladeRectangle(cut: 18))
    }

    private func tradePill(image: String, text: String, tint: Color)
        -> some View
    {
        HStack(spacing: 8) {
            RemoteAssetImage(name: image)
                .scaledToFit()
                .frame(width: 26, height: 26)

            Text(text)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .background(black.opacity(0.58))
        .overlay(
            ExchangeBladeRectangle(cut: 9).stroke(
                tint.opacity(0.78),
                lineWidth: 1.2
            )
        )
        .clipShape(ExchangeBladeRectangle(cut: 9))
    }
}

private struct ExchangeBladeShape: Shape {
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

private struct ExchangeBladeRectangle: Shape {
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
    ExchangeView()
}
