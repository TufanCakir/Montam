//
//  RemoteContentLoadingOverlay.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct RemoteContentLoadingOverlay: View {
    let text: String

    var body: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(.cyan)

            Text(text)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(
                .cyan.opacity(0.5),
                lineWidth: 1
            )
        )
    }
}
