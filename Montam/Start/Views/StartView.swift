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

    @State private var presentedOverlay: StartOverlay?
    @State private var menuMessage: String?
    @State private var isLogoOpen = false
    @State private var backgroundImageName = "bg_tropical_beach"
    @State private var remoteContent = RemoteContentService.shared
    @AppStorage(AppLocalizationService.languageKey) private
        var languageRawValue =
        AppLocalizationService.fallbackLanguage.rawValue

    var body: some View {
        ZStack {
            mainContent

            if presentedOverlay != nil {
                Color.black.opacity(0.62)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeOverlays()
                    }
            }

            if presentedOverlay == .menu {
                StartMenuPanel(
                    onSettings: {
                        withAnimation(
                            .spring(response: 0.28, dampingFraction: 0.86)
                        ) {
                            presentedOverlay = .settings
                        }
                    },
                    onCacheClear: {
                        clearCacheAndReload()
                    },
                    onLegal: {
                        withAnimation(
                            .spring(response: 0.28, dampingFraction: 0.86)
                        ) {
                            presentedOverlay = .legal
                        }
                    },
                    onClose: closeOverlays
                )
                .environment(\.menuMessage, menuMessage)
                .transition(.scale.combined(with: .opacity))
            }

            if presentedOverlay == .settings {
                AppSettingsPanel(
                    onClose: closeOverlays,
                    onDataDeleted: {
                        closeOverlays()
                        onDataDeleted()
                    },
                    onCacheCleared: {
                        closeOverlays()
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }

            if presentedOverlay == .legal {
                AppLegalPanel(
                    onClose: {
                        withAnimation(
                            .spring(response: 0.28, dampingFraction: 0.86)
                        ) {
                            presentedOverlay = .menu
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            isLogoOpen = false

            withAnimation(.easeOut(duration: 1.15).delay(0.2)) {
                isLogoOpen = true
            }

            if let remote = Self.launchBackgroundImageName(),
                RemoteContentService.cachedAssetExists(named: remote)
            {
                backgroundImageName = remote
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {

            RevealingLogo(progress: isLogoOpen ? 1 : 0)
                

            Button(action: onStart) {
                startPrompt
            }
            .buttonStyle(.plain)
            .disabled(remoteContent.isUpdating)

            bottomRow
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            StartBackgroundImage(imageName: backgroundImageName)
        }
    }

    private var startPrompt: some View {
        Text(
            remoteContent.isUpdating
                ? localized("start.downloading")
                : localized("start.touchToStart")
        )
        .font(.system(size: 17, weight: .heavy, design: .rounded))
        .foregroundStyle(.white)
        .padding()
        .background(
            LinearGradient(
                colors: [.clear, .blue.opacity(0.80), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .opacity(remoteContent.isUpdating ? 0.6 : 1)
    }

    private var bottomRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                RemoteAssetImage(imageName: "montem_badge_logo")
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                Text(AppBundleInfo.versionDisplay)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .frame(width: 142, height: 28)
                    .background(.black)
                    .clipShape(Capsule())

                Text(localized("start.copyright"))
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 2, x: 1, y: 2)
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    presentedOverlay = .menu
                }
            } label: {
                Text(localized("start.menu"))
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 48)
                    .background(
                        LinearGradient(
                            colors: [.blue, .blue],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(
                            .yellow,
                            lineWidth: 2
                        )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func closeOverlays() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            presentedOverlay = nil
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

    private func clearCacheAndReload() {
        AppSettingsService.clearCache()
        showMenuMessage(localized("settings.cacheCleared"))

        Task {
            await remoteContent.updateAtLaunch(showOverlay: true)
        }
    }

    private static func launchBackgroundImageName() -> String? {
        let backgrounds =
            JSONDataLoader.load("background", as: [BackgroundData].self) ?? []
        return backgrounds.compactMap(\.resolvedBackgroundImageName).first
    }

    private func localized(_ key: String) -> String {
        AppLocalizationService.text(key)
    }
}

private enum StartOverlay {
    case menu
    case settings
    case legal
}

private struct StartBackgroundImage: View {
    let imageName: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppScreenBackground()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                if let imageName {

                    if RemoteContentService.cachedAssetExists(named: imageName)
                    {
                        RemoteAssetImage(imageName: imageName)
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .clipped()
                    } else {
                        Image("bg_tropical_beach")
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                            .clipped()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

private struct StartMenuPanel: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.menuMessage) private var message
    @AppStorage(AppLocalizationService.languageKey) private
        var languageRawValue =
        AppLocalizationService.fallbackLanguage.rawValue
    var onSettings: () -> Void = {}
    var onCacheClear: () -> Void = {}
    var onLegal: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            menuHeader

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    languagePicker

                    StartMenuButton(
                        title: localized("settings.title"),
                        icon: "gear",
                        action: onSettings
                    )
                    StartMenuButton(
                        title: localized("settings.clearCache"),
                        icon: "trash.fill",
                        action: onCacheClear
                    )
                    StartMenuButton(
                        title: localized("start.legal"),
                        icon: "doc.text.fill",
                        action: onLegal
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

                    Text(localized("start.social"))
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
                                icon: link.systemIcon
                            ) {
                                openURL(link.url)
                            }
                        }
                    }
                }
                .padding(18)
            }
            .frame(maxHeight: 520)
            .gamePanelBodyBackground()
        }
        .gamePanelFrame(width: 360)
    }

    private var menuHeader: some View {
        GamePanelHeader(title: localized("start.menu"), onClose: onClose)
            .overlay(StartSquarePattern().opacity(0.22))
    }

    private var languagePicker: some View {
        Picker(localized("settings.language"), selection: $languageRawValue) {
            ForEach(AppLanguage.allCases) { language in
                Text(localized(language.titleKey))
                    .tag(language.rawValue)
            }
        }
        .pickerStyle(.segmented)
    }

    private func localized(_ key: String) -> String {
        AppLocalizationService.text(key)
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
                        colors: [.blue, .blue],
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

private struct RevealingLogo: View, Animatable {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        GeometryReader { geometry in
            let clampedProgress = min(max(progress, 0), 1)
            let revealWidth = geometry.size.width * clampedProgress

            ZStack(alignment: .leading) {
                RemoteAssetImage(imageName: "montam_logo")
                    .scaledToFit()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: revealWidth)
                    }

                if clampedProgress > 0 && clampedProgress < 1 {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.82),
                                    .clear,
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 34)
                        .offset(x: revealWidth - 17)
                        .blendMode(.screen)
                }
            }
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
