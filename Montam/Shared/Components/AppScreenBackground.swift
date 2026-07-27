//
//  AppScreenBackground.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct AppScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.06, blue: 0.2),
                Color(red: 0.0, green: 0.14, blue: 0.42),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .top) {
            AppScreenLinePattern()
                .opacity(0.42)
        }
    }
}

private struct AppScreenLinePattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 4
            let lineCount = Int(size.height / spacing)
            let color = Color.cyan.opacity(0.16)

            for index in 0...lineCount {
                let y = CGFloat(index) * spacing
                let rect = CGRect(x: 0, y: y, width: size.width, height: 1)
                context.fill(Path(rect), with: .color(color))
            }
        }
    }
}
