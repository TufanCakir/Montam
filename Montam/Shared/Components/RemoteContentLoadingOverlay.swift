//
//  RemoteContentLoadingOverlay.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct RemoteContentLoadingOverlay: View {
    let text: String
    let progress: Double
    let detailText: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.38)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressView()
                    .tint(.cyan)

                Text(text)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                ProgressView(value: clampedProgress)
                    .progressViewStyle(.linear)
                    .tint(.cyan)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    Text(detailText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(progressPercentText)
                        .monospacedDigit()
                }
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(width: 240)
            .background(Color.black.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(
                    .cyan.opacity(0.5),
                    lineWidth: 1
                )
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityValue("\(detailText), \(progressPercentText)")
    }

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private var progressPercentText: String {
        "\(Int((clampedProgress * 100).rounded()))%"
    }
}
