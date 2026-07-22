//
//  SummonComponents.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct SummonTitleBar: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("Spezialbeschwörung")
                .font(.system(size: 25, weight: .heavy, design: .rounded))
                .foregroundStyle(.cyan)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .shadow(color: .black.opacity(0.55), radius: 2, x: 1, y: 2)

            Text("i")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
                .background(.cyan)
                .clipShape(Circle())

            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(height: 48)
        .background(Color.black.opacity(0.12))
    }
}

struct SummonCategoryPicker: View {
    let categories: [SummonCategoryData]
    @Binding var selectedCategoryId: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    Button {
                        selectedCategoryId = category.id
                    } label: {
                        Text(category.title)
                            .font(
                                .system(
                                    size: 16,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selectedCategoryId == category.id
                                    ? .black : .white
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, 18)
                            .frame(height: 34)
                            .background(
                                selectedCategoryId == category.id
                                    ? Color.yellow : Color.blue.opacity(0.78)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8).stroke(
                                    .black.opacity(0.6),
                                    lineWidth: 1.5
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

struct SummonBannerPageList: View {
    let summons: [SummonData]
    let onSummon: (SummonData, Int) -> Void

    var body: some View {
        LazyVStack(spacing: 18) {
            ForEach(summons, id: \.id) { summon in
                VStack(spacing: 12) {
                    SummonLargeBannerCard(summon: summon)
                    SummonActionRow(summon: summon, onSummon: onSummon)
                }
                .scrollTargetLayout()
            }
        }
    }
}

struct SummonActionRow: View {
    let summon: SummonData
    let onSummon: (SummonData, Int) -> Void

    var body: some View {
        HStack(spacing: 12) {
            SummonActionButton(
                count: 1,
                cost: summon.singleCost ?? 0,
                currency: summon.currency
            ) {
                onSummon(summon, 1)
            }

            SummonActionButton(
                count: 10,
                cost: summon.multiCost ?? 0,
                currency: summon.currency
            ) {
                onSummon(summon, 10)
            }
        }
    }
}

struct SummonActionButton: View {
    let count: Int
    let cost: Int
    let currency: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    GameResourceIcon(id: currency, fallbackImage: nil)
                        .frame(width: 24, height: 24)
                    Text("\(cost)")
                        .font(
                            .system(size: 19, weight: .black, design: .rounded)
                        )
                }

                Text(count == 1 ? "1x beschwören" : "10x beschwören")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(count == 10 ? .brown : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(count == 10 ? Color.yellow : Color.cyan)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(
                    .black.opacity(0.78),
                    lineWidth: 2
                )
            )
            .shadow(color: .black.opacity(0.25), radius: 0, x: 2, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct SummonEmptyState: View {
    var body: some View {
        Text("Keine Beschwörung in dieser Kategorie")
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.blue.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 10))
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

struct SummonLargeBannerCard: View {
    let summon: SummonData

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summon.title)
                        .font(
                            .system(size: 23, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                        .shadow(color: .black, radius: 2, x: 1, y: 2)

                    Text(summon.description ?? "")
                        .font(
                            .system(size: 13, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 8)

                GameResourceIcon(id: summon.currency, fallbackImage: nil)
                    .frame(width: 34, height: 34)
            }

            SummonBannerArtwork(summon: summon)
                .frame(maxWidth: .infinity)
                .frame(height: 245)
                .background(SummonCircleDecoration())
                .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 10) {
                Text("Garantie")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)

                ProgressView(
                    value: 0,
                    total: Double(max(summon.guaranteedAfter ?? 1, 1))
                )
                .tint(.green)

                Text("0/\(summon.guaranteedAfter ?? 0)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.green)
            }
            .padding(10)
            .background(Color.blue.opacity(0.42))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(
                    .cyan.opacity(0.55),
                    lineWidth: 2
                )
            )
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    .blue.opacity(0.58), .cyan.opacity(0.28),
                    .white.opacity(0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
                .cyan.opacity(0.62),
                lineWidth: 2
            )
        )
    }
}

struct SummonBannerArtwork: View {
    let summon: SummonData

    var body: some View {
        if summon.renderMode != "generated", let imageName = summon.bannerImage,
            !imageName.isEmpty
        {
            RemoteAssetImage(imageName: imageName)
                .scaledToFit()
                .padding(.vertical, 6)
        } else {
            generatedArtwork
                .padding(18)
        }
    }

    private var generatedArtwork: some View {
        let accent = Color(hex: summon.accentColor ?? "") ?? .cyan

        return HStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { index in
                generatedTile(index: index, accent: accent)
                    .rotationEffect(.degrees(Double(index - 1) * 10))
                    .offset(y: CGFloat(index % 2 == 0 ? 12 : -18))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func generatedTile(index: Int, accent: Color) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(
                LinearGradient(
                    colors: [accent.opacity(0.95), .blue.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: index == 1 ? 98 : 72, height: index == 1 ? 138 : 108)
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(
                    .white.opacity(0.75),
                    lineWidth: 2
                )
            )
            .overlay {
                generatedSymbol
                    .foregroundStyle(.white)
                    .padding(index == 1 ? 24 : 18)
            }
            .shadow(color: accent.opacity(0.55), radius: 10, x: 0, y: 0)
    }

    @ViewBuilder
    private var generatedSymbol: some View {
        switch summon.iconShape {
        case "cards":
            VStack(spacing: -28) {
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 5)
                    .rotationEffect(.degrees(-14))
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 5)
                    .rotationEffect(.degrees(8))
            }
        case "ticket":
            GameResourceIcon(id: summon.currency, fallbackImage: nil)
        case "monster":
            GeneratedTabIcon(id: "montam", isSelected: true)
        default:
            SparkView()
        }
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

struct SummonGeneratedBackground: View {
    var body: some View {
        AppScreenBackground()
    }
}

struct SummonCircleDecoration: View {
    var body: some View {
        Circle()
            .fill(.cyan.opacity(0.14))
            .overlay(Circle().stroke(.cyan.opacity(0.32), lineWidth: 12))
            .overlay {
                VStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { _ in
                        HStack(spacing: 8) {
                            ForEach(0..<8, id: \.self) { _ in
                                Circle()
                                    .fill(.blue.opacity(0.24))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
            .padding(20)
    }
}

struct SummonSideChevron: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.cyan.opacity(0.9))
                .frame(width: 34, height: 54)
                .background(Color.cyan.opacity(0.14))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(.cyan.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
