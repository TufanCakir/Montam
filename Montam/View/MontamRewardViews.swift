//
//  MontamRewardViews.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct MontamRewardChip: View {
    let title: String
    let value: Int
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            RemoteAssetImage(name: icon)
                .scaledToFit()
                .frame(width: 18, height: 18)

            Text("+\(value)")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 9)
        .frame(height: 30)
        .background(MontamPalette.black)
        .overlay(
            MontamCutRectangle(cut: 7)
                .stroke(MontamPalette.gold.opacity(0.7), lineWidth: 1)
        )
        .clipShape(MontamCutRectangle(cut: 7))
        .accessibilityLabel("\(title) \(value)")
    }
}

struct MontamRewardLine: View {
    let title: String
    let value: Int
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            RemoteAssetImage(name: icon)
                .scaledToFit()
                .frame(width: 26, height: 26)

            Text(title)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)

            Spacer()

            Text("+\(value)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct MontamStarRow: View {
    let stars: Int
    var size: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: max(2, size * 0.20)) {
            starLine(range: 1...7, activeColor: MontamPalette.gold)

            if stars > 7 {
                starLine(range: 8...14, activeColor: MontamPalette.blue)
            }
        }
        .accessibilityLabel("\(stars) Stars")
    }

    private func starLine(range: ClosedRange<Int>, activeColor: Color)
        -> some View
    {
        HStack(spacing: max(1, size * 0.16)) {
            ForEach(Array(range), id: \.self) { index in
                BladeStar()
                    .fill(
                        index <= stars
                            ? activeColor : MontamPalette.panelLight
                    )
                    .frame(width: size, height: size)
                    .overlay(
                        BladeStar()
                            .stroke(
                                index <= stars
                                    ? .white.opacity(0.36)
                                    : .white.opacity(0.08),
                                lineWidth: max(0.7, size * 0.08)
                            )
                    )
                    .opacity(index <= stars ? 1 : 0.45)
            }
        }
    }
}

private struct BladeStar: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) * 0.50
        let inner = outer * 0.44
        var path = Path()

        for index in 0..<10 {
            let angle = (-CGFloat.pi / 2) + CGFloat(index) * (.pi / 5)
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}
