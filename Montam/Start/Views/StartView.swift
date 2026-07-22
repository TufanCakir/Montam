//
//  StartView.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct StartView: View {

    var onStart: () -> Void = {}
    var onDataDeleted: () -> Void = {}

    @State private var isMenuPresented = false
    @State private var isSettingsPresented = false
    @State private var menuMessage: String?
    @State private var logoPulse = false
    @State private var background = PixelEnvironmentCatalog.randomBackground()

    var body: some View {
        ZStack {
            mainContent
                .blur(radius: isMenuPresented || isSettingsPresented ? 8 : 0)

            if isMenuPresented || isSettingsPresented {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeOverlays()
                    }
            }

            if isMenuPresented {
                StartMenuPanel(
                    onSettings: {
                        withAnimation(
                            .spring(response: 0.28, dampingFraction: 0.86)
                        ) {
                            isMenuPresented = false
                            isSettingsPresented = true
                        }
                    },
                    onCacheClear: {
                        AppSettingsService.clearCache()
                        showMenuMessage("Cache geleert.")
                    },
                    onClose: closeOverlays
                )
                .environment(\.menuMessage, menuMessage)
                .transition(.scale.combined(with: .opacity))
            }

            if isSettingsPresented {
                AppSettingsPanel(
                    onClose: closeOverlays,
                    onDataDeleted: {
                        closeOverlays()
                        onDataDeleted()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            logoPulse = true
        }
    }

    private var mainContent: some View {
        ZStack {
            PixelEnvironmentView(
                data: background,
                groundRatio: 0.28
            )

            VStack(spacing: 0) {
                topBrandRow
                    .padding(.top, 72)

                Spacer()

                Image("montam_logo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 34)
                    .scaleEffect(logoPulse ? 1.02 : 0.98)
                    .shadow(color: .cyan.opacity(0.7), radius: 16)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(
                            autoreverses: true
                        ),
                        value: logoPulse
                    )

                Spacer()

                Button(action: onStart) {
                    startPrompt
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 100)
                .padding(.bottom, 84)

                bottomRow
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
    }

    private var topBrandRow: some View {
        HStack(alignment: .top) {
            VStack(spacing: 18) {

                MontamStudioBadge()
                    .frame(width: 116, height: 76)

                Text(AppBundleInfo.versionDisplay)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue.opacity(0.75))
                    .frame(width: 142, height: 28)
                    .background(.white)
                    .clipShape(Capsule())
            }

            Spacer()

            Text("MONTAM")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white)
                        .frame(height: 3)
                        .offset(y: 4)
                }
                .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 2)
                .padding(.top, 10)
        }
        .padding(.horizontal, 56)
    }

    private var startPrompt: some View {
        Text("Touch To Start")
            .font(.system(size: 25, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.95))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.clear, .cyan.opacity(0.62), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)
    }

    private var bottomRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                MontamBadge()
                    .frame(width: 54, height: 54)

                Text("© 2026 Tufan Cakir. All rights reserved.")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 2)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isMenuPresented = true
                }
            } label: {
                Text("Menü")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 48)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(
                            .black.opacity(0.75),
                            lineWidth: 2
                        )
                    )
                    .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
    }

    private func closeOverlays() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            isMenuPresented = false
            isSettingsPresented = false
        }
    }

    private func showMenuMessage(_ text: String) {
        menuMessage = text

        Task {
            try? await Task.sleep(for: .seconds(1.4))
            if menuMessage == text {
                menuMessage = nil
            }
        }
    }
}

private struct StartMenuPanel: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.menuMessage) private var message
    var onSettings: () -> Void = {}
    var onCacheClear: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            menuHeader

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    StartMenuButton(
                        title: "Einstellungen",
                        icon: "gear",
                        action: onSettings
                    )
                    StartMenuButton(
                        title: "Cache leeren",
                        icon: "trash.fill",
                        action: onCacheClear
                    )

                    if let message {
                        Text(message)
                            .font(
                                .system(
                                    size: 13,
                                    weight: .heavy,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.cyan)
                    }

                    Text("Social")
                        .font(
                            .system(size: 17, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                        ],
                        spacing: 10
                    ) {
                        ForEach(AppSocialLink.all) { link in
                            StartMenuButton(
                                title: link.title,
                                icon: icon(for: link.id)
                            ) {
                                openURL(link.url)
                            }
                        }
                    }
                }
                .padding(18)
            }
            .frame(maxHeight: 520)
            .background(Color(red: 0.04, green: 0.16, blue: 0.34))
        }
        .frame(width: 360)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.blue, lineWidth: 3))
    }

    private var menuHeader: some View {
        HStack {
            Text("Menü")
                .font(.system(size: 31, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .frame(height: 64)
        .background(
            LinearGradient(
                colors: [.blue, .cyan.opacity(0.75)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .overlay(StartSquarePattern().opacity(0.22))
        )
    }

    private func icon(for id: String) -> String {
        switch id {
        case "youtube": "play.rectangle.fill"
        case "instagram": "camera.fill"
        case "x": "xmark"
        case "facebook": "f.circle.fill"
        case "tiktok": "music.note"
        case "threads": "at"
        case "github": "chevron.left.forwardslash.chevron.right"
        case "discord": "bubble.left.and.bubble.right.fill"
        case "linkedin": "person.crop.square.fill"
        default: "link"
        }
    }
}

private struct StartMenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(
                        .black.opacity(0.78),
                        lineWidth: 2
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct MontamStudioBadge: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7).stroke(
                        .blue,
                        lineWidth: 3
                    )
                )

            Text("Tufan\nCakir")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(-4)
        }
    }
}

private struct MontamBadge: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("montem_badge_logo")
                .resizable()
                .scaledToFit()
        }
    }
}

private struct StartSquarePattern: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        index.isMultiple(of: 3)
                            ? .white.opacity(0.5) : .blue.opacity(0.55)
                    )
                    .frame(
                        width: CGFloat(6 + index % 4 * 5),
                        height: CGFloat(6 + index % 4 * 5)
                    )
            }
        }
    }
}

private struct StartMenuMessageKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    fileprivate var menuMessage: String? {
        get { self[StartMenuMessageKey.self] }
        set { self[StartMenuMessageKey.self] = newValue }
    }
}

#Preview {
    StartView()
}
