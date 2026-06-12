//
//  MontamStyle.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

enum MontamPalette {
    static let black = Color(red: 0.012, green: 0.016, blue: 0.026)

    static let panel = Color(red: 0.044, green: 0.065, blue: 0.105)
    static let panelLight = Color(red: 0.075, green: 0.105, blue: 0.165)

    // Core
    static let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    static let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    static let red = Color(red: 0.82, green: 0.16, blue: 0.22)
    static let white = Color(red: 1.0, green: 1.0, blue: 1.0)
    
    // Added resource colors
    static let emerald = Color(red: 0.10, green: 0.78, blue: 0.48)
    static let violet = Color(red: 0.55, green: 0.34, blue: 0.92)
    static let cyan = Color(red: 0.12, green: 0.82, blue: 0.92)
    static let amber = Color(red: 1.00, green: 0.58, blue: 0.10)
    static let crimson = Color(red: 0.88, green: 0.20, blue: 0.30)

    static let mutedText = Color.white.opacity(0.62)
}

struct MontamCutRectangle: Shape {
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

struct MontamEvolutionShape: Shape {
    func path(in rect: CGRect) -> Path {
        let corner = min(rect.width, rect.height) * 0.16
        let notch = min(rect.width, rect.height) * 0.10

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + corner, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - corner, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + corner))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - corner))
        path.addLine(to: CGPoint(x: rect.midX + notch, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - notch, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - corner))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + corner))
        path.closeSubpath()
        return path
    }
}

struct MontamBackground: View {
    private var backgroundImage: String {
        GameConfigManager.shared.config.homeBackgroundImage ?? "montam_bg_dark"
    }

    var body: some View {
        RemoteAssetImage(name: backgroundImage)
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct MontamScreenBackground: View {
    var body: some View {
        MontamBackground()
            .overlay(
                LinearGradient(
                    colors: [
                        MontamPalette.black.opacity(0.18),
                        MontamPalette.black.opacity(0.08),
                        MontamPalette.black.opacity(0.30),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
    }
}
