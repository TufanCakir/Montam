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
        .ignoresSafeArea()
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

struct GameConfirmationPopup: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    var icon: String = "questionmark.circle.fill"
    var isDestructive = false
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(isDestructive ? .red : .yellow)

            Text(title)
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(message)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.72)

            HStack(spacing: 10) {
                Button(action: onCancel) {
                    Text(cancelTitle)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.black.opacity(0.34))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text(confirmTitle)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundStyle(isDestructive ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(isDestructive ? Color.red : Color.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(width: 320)
        .background(Color(red: 0.03, green: 0.13, blue: 0.30).opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.cyan.opacity(0.9), lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.55), radius: 18, y: 10)
    }
}
