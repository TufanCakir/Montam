//
//  SummonResultView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct SummonResultView: View {
    let title: String
    let results: [SummonResultItem]
    let onClose: () -> Void

    @State private var revealedCount = 0

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Beschwörungsergebnis")
                        .font(
                            .system(size: 28, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(title)
                        .font(
                            .system(size: 15, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .lineLimit(1)
                }

                Spacer()

                Button("OK") {
                    onClose()
                }
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(height: 42)
                .background(Color.cyan.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(
                        .white.opacity(0.55),
                        lineWidth: 2
                    )
                )
            }

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(results.enumerated()), id: \.element.id) {
                        index,
                        item in
                        SummonResultCard(item: item)
                            .opacity(index < revealedCount ? 1 : 0)
                            .scaleEffect(index < revealedCount ? 1 : 0.72)
                            .rotation3DEffect(
                                .degrees(index < revealedCount ? 0 : -16),
                                axis: (x: 1, y: 0, z: 0)
                            )
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 64)
        .padding(.bottom, 26)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SummonResultBackground())
        .task {
            revealedCount = 0

            for index in results.indices {
                try? await Task.sleep(for: .milliseconds(index == 0 ? 120 : 85))

                withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) {
                    revealedCount = index + 1
                }
            }
        }
    }
}

struct SummonResultItem: Identifiable {
    enum Kind {
        case monster
        case tamer
        case supportCard
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let rarity: String
    let kind: Kind
    let imageName: String?
    let accentColor: Color
    let symbolId: String
}

private struct SummonResultCard: View {
    let item: SummonResultItem

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(item.rarity.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .frame(height: 25)
                    .background(item.accentColor)
                    .clipShape(Capsule())

                Spacer()
            }

            resultArtwork
                .frame(height: 148)
                .frame(maxWidth: .infinity)
                .background(
                    ResultCircleDecoration(accentColor: item.accentColor)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(spacing: 2) {
                Text(item.title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(item.subtitle)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.86), item.accentColor.opacity(0.34),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(
                item.accentColor.opacity(0.9),
                lineWidth: 2
            )
        )
        .shadow(color: item.accentColor.opacity(0.35), radius: 8, x: 0, y: 0)
    }

    @ViewBuilder
    private var resultArtwork: some View {
        if let imageName = item.imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        } else {
            GeneratedSupportCardResult(item: item)
                .padding(18)
        }
    }
}

private struct GeneratedSupportCardResult: View {
    let item: SummonResultItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            item.accentColor.opacity(0.95), .blue.opacity(0.85),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .rotationEffect(.degrees(-7))

            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.75), lineWidth: 3)
                .rotationEffect(.degrees(-7))

            cardSymbol
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
        }
        .frame(width: 116, height: 150)
    }

    @ViewBuilder
    private var cardSymbol: some View {
        switch item.symbolId {
        case "cards":
            VStack(spacing: -30) {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 6)
                    .rotationEffect(.degrees(-12))
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 6)
                    .rotationEffect(.degrees(10))
            }
        case "ticket":
            GameResourceIcon(id: "summon_ticket", fallbackImage: nil)
        case "monster":
            GeneratedTabIcon(id: "montam", isSelected: true)
        default:
            ResultSparkShape()
        }
    }
}

private struct ResultCircleDecoration: View {
    let accentColor: Color

    var body: some View {
        Circle()
            .fill(accentColor.opacity(0.15))
            .overlay(Circle().stroke(accentColor.opacity(0.28), lineWidth: 10))
            .overlay {
                VStack(spacing: 7) {
                    ForEach(0..<6, id: \.self) { _ in
                        HStack(spacing: 7) {
                            ForEach(0..<6, id: \.self) { _ in
                                Circle()
                                    .fill(.white.opacity(0.18))
                                    .frame(width: 7, height: 7)
                            }
                        }
                    }
                }
            }
            .padding(12)
    }
}

private struct ResultSparkShape: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 12, height: 72)
            Rectangle()
                .frame(width: 72, height: 12)
            Circle()
                .frame(width: 22, height: 22)
        }
    }
}

private struct SummonResultBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

#Preview {
    SummonResultView(
        title: "Support Summon",
        results: [
            SummonResultItem(
                title: "Kael",
                subtitle: "Tamer Support",
                rarity: "SSR",
                kind: .tamer,
                imageName: "tamer_kael",
                accentColor: .purple,
                symbolId: "support"
            ),
            SummonResultItem(
                title: "Kael",
                subtitle: "Tamer Support",
                rarity: "R",
                kind: .tamer,
                imageName: "tamer_kael",
                accentColor: .blue,
                symbolId: "support"
            ),
            SummonResultItem(
                title: "Support Karte",
                subtitle: "Bonuskarte",
                rarity: "SR",
                kind: .supportCard,
                imageName: nil,
                accentColor: .orange,
                symbolId: "cards"
            ),
        ],
        onClose: {}
    )
}
