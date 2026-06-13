//
//  StartView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import SwiftUI

struct StartView: View {
    @EnvironmentObject private var appModel: AppModel
    @ObservedObject private var remote = RemoteDownloadManager.shared

    @State private var isCheckingUpdate = false
    @State private var showUpdateDialog = false
    @State private var showSupportMenu = false
    @State private var featuredCharacters: [Character] = []
    @State private var featuredIndex = 0
    @State private var showResetConfirmation = false
    @State private var supportStatusMessage = "Bereit"

    private let black = MontamPalette.black
    private let panel = MontamPalette.panel
    private let gold = MontamPalette.gold
    private let blue = MontamPalette.blue
    private let montamRotationTimer = Timer.publish(
        every: 2.8,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack {
            startContent
                .blur(radius: showSupportMenu ? 7 : 0)
                .scaleEffect(showSupportMenu ? 0.97 : 1)
                .animation(.smooth(duration: 0.28), value: showSupportMenu)

            if showSupportMenu {
                supportMenuOverlay
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(
                                with: .move(edge: .bottom)
                            ),
                            removal: .opacity
                        )
                    )
                    .zIndex(3)
            }
        }
        .background {
            MontamBackground()
        }
        .alert("Neues Update gefunden", isPresented: $showUpdateDialog) {
            Button("Abbrechen", role: .cancel) {}
            Button("Update starten") {
                startPreloadThenGame()
            }
        } message: {
            Text(
                "Neue Spieldaten sind verfügbar. Diese werden jetzt heruntergeladen, damit du die aktuellste Version spielen kannst."
            )
        }
        .alert(
            "Spielstand wirklich löschen?",
            isPresented: $showResetConfirmation
        ) {
            Button("Abbrechen", role: .cancel) {}
            Button("Alles löschen", role: .destructive) {
                closeSupportMenu()
                appModel.fullReset()
            }
        } message: {
            Text(
                "Dein lokaler Spielstand, Starter, Fortschritt, Währungen und Inventare werden zurückgesetzt. Diese Aktion kann nicht rückgängig gemacht werden."
            )
        }
        .overlay {
            if isCheckingUpdate || remote.isLoading {
                loadingOverlay
                    .zIndex(4)
            }
        }
        .animation(
            .spring(response: 0.36, dampingFraction: 0.88),
            value: showSupportMenu
        )
        .onAppear {
            remote.refreshManifest()
            loadFeaturedCharacters()
        }
        .onReceive(montamRotationTimer) { _ in
            rotateFeaturedMontam()
        }
    }

    private var startContent: some View {
        VStack(spacing: 0) {
            Spacer()

            montamShowcase

            Spacer()

            startPrompt

            Spacer()

            copyrightPrompt
        }
        .padding(.horizontal, 22)
        .contentShape(Rectangle())
        .onTapGesture {
            beginStartFlow()
        }
        .overlay(alignment: .bottomTrailing) {
            supportButton
        }
    }

    private var supportMenuOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.36))
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture {
                    closeSupportMenu()
                }

            supportMenu
                .padding(.horizontal, 18)
                .padding(.vertical, 34)
        }
    }

    private func openSupportMenu() {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
            showSupportMenu = true
        }
    }

    private func closeSupportMenu() {
        withAnimation(.smooth(duration: 0.22)) {
            showSupportMenu = false
        }
    }

    private var featuredMontam: Character? {
        guard featuredCharacters.indices.contains(featuredIndex) else {
            return featuredCharacters.first
        }

        return featuredCharacters[featuredIndex]
    }

    private var montamShowcase: some View {
        ZStack {
            if let featuredMontam {
                VStack(spacing: 8) {
                    RemoteAssetImage(name: featuredMontam.sprite)
                        .scaledToFit()
                        .id(featuredMontam.id)
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(
                                    with: .scale(scale: 0.92)
                                ),
                                removal: .opacity.combined(
                                    with: .scale(scale: 1.06)
                                )
                            )
                        )
                }
            } else {
                RemoteAssetImage(name: "skin_cryon_feral_default")
                    .scaledToFit()
                    .frame(width: 210, height: 210)
            }
        }
        .animation(
            .spring(response: 0.42, dampingFraction: 0.82),
            value: featuredIndex
        )
    }

    private var startPrompt: some View {
        VStack(spacing: 11) {
            Text("BERÜHREN")
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(gold)
                .shadow(color: black, radius: 10)
        }
        .offset(y: -100)
        .allowsHitTesting(false)
    }

    private var copyrightPrompt: some View {
        VStack(spacing: 11) {
            Text("© 2026 Tufan Cakir")
            Text("All Rights Reserved")

        }
        .foregroundStyle(.white)
        .font(.system(size: 10, weight: .black, design: .rounded))
        .shadow(color: black, radius: 10)
    }

    private var supportButton: some View {
        Button {
            openSupportMenu()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24, weight: .black))
                Text("Support")
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .foregroundStyle(black)
            .frame(width: 82, height: 58)
            .background(gold)
            .overlay(
                MontamCutRectangle(cut: 9)
                    .stroke(black.opacity(0.85), lineWidth: 2)
            )
            .clipShape(MontamCutRectangle(cut: 9))
        }
        .buttonStyle(.plain)
        .padding()
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text(
                    isCheckingUpdate
                        ? "NACH UPDATES SUCHEN"
                        : "SPIELDATEN LADEN"
                ).font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(remote.statusText.uppercased())
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(gold)
                    .multilineTextAlignment(.center)

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(black.opacity(0.86))

                        Rectangle()
                            .fill(gold)
                            .frame(
                                width: proxy.size.width
                                    * (isCheckingUpdate
                                        ? 0.18 : remote.progress)
                            )
                    }
                }
                .frame(height: 15)
                .overlay(
                    MontamCutRectangle(cut: 5)
                        .stroke(blue, lineWidth: 1.4)
                )
                .clipShape(MontamCutRectangle(cut: 5))

                HStack {
                    Text("\(Int(remote.progress * 100))%")
                    Spacer()
                    Text("\(remote.completedItems) / \(remote.totalItems)")
                    Spacer()
                    Text(remote.formattedBytes(remote.downloadedBytes))
                }
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
            }
            .padding(18)
            .frame(maxWidth: 330)
            .background(panel.opacity(0.96))
            .overlay(
                MontamCutRectangle(cut: 18)
                    .stroke(gold, lineWidth: 2)
            )
            .clipShape(MontamCutRectangle(cut: 18))
        }
    }

    private var supportMenu: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Support")
                            .font(
                                .system(
                                    size: 28,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(gold)

                        Text("Daten, Cache und Links")
                            .font(
                                .system(
                                    size: 12,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer()

                    Button {
                        closeSupportMenu()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(black)
                            .frame(width: 48, height: 48)
                            .background(gold)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                LazyVGrid(
                    columns: supportColumns,
                    spacing: 14
                ) {
                    supportActionButton("Aktualisieren") {
                        supportStatusMessage = "Synchronisiere Spieldaten..."
                        remote.preload {
                            supportStatusMessage = "Spieldaten aktualisiert."
                        }
                    }
                    supportActionButton("Alle Inhalte herunterladen") {
                        supportStatusMessage = "Lade alle Inhalte..."
                        remote.downloadAll {
                            supportStatusMessage =
                                "Alle Inhalte gespeichert: \(remote.formattedBytes(remote.downloadedBytes))"
                        }
                    }
                    supportActionButton("Speicher leeren") {
                        remote.clearCache()
                        supportStatusMessage = "Cache wurde geleert."
                    }
                    supportActionButton("Spiel zurücksetzen") {
                        showResetConfirmation = true
                    }
                }

                supportDownloadStatus

                sectionTitle("Social")

                LazyVGrid(
                    columns: socialColumns,
                    spacing: 12
                ) {
                    ForEach(socialLinks) { item in
                        socialLinkButton(item)
                    }
                }

                Text(
                    "Tippe auf einen Link, um ihn in der passenden App zu öffnen."
                )
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
                .padding(.bottom, 18)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: 520)
        .frame(maxHeight: 720)
        .onTapGesture {}
    }

    private var supportColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    }

    private var socialColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    }

    private var socialLinks: [SocialLink] {
        [
            SocialLink(
                title: "YouTube",
                systemImage: "play.rectangle.fill",
                url: "https://www.youtube.com/@TufanCakirOfficial"
            ),
            SocialLink(
                title: "X",
                systemImage: "xmark",
                url: "https://x.com/tufan_cakir_?s=11"
            ),
            SocialLink(
                title: "Facebook",
                systemImage: "f.circle.fill",
                url:
                    "https://www.facebook.com/share/19698YZa8H/?mibextid=wwXIfr"
            ),
            SocialLink(
                title: "TikTok",
                systemImage: "music.note",
                url:
                    "https://www.tiktok.com/@tufanwhiteandblack?_r=1&_t=ZG-97BEe6GSSoq"
            ),
            SocialLink(
                title: "LinkedIn",
                systemImage: "person.text.rectangle.fill",
                url:
                    "https://www.linkedin.com/in/tufan-cakir?utm_source=share_via&utm_content=profile&utm_medium=member_ios"
            ),
            SocialLink(
                title: "Threads",
                systemImage: "at",
                url:
                    "https://www.threads.com/@tufan_cakir_?igshid=NTc4MTIwNjQ2YQ=="
            ),
            SocialLink(
                title: "GitHub",
                systemImage: "chevron.left.forwardslash.chevron.right",
                url: "https://github.com/TufanCakir"
            ),
            SocialLink(
                title: "Instagram",
                systemImage: "camera.fill",
                url: "https://www.instagram.com/tufan_cakir_?utm_source=qr"
            ),
            SocialLink(
                title: "Discord",
                systemImage: "bubble.left.and.bubble.right.fill",
                url: "https://discord.gg/zvyc66rkx"
            ),
            SocialLink(
                title: "Portfolio",
                systemImage: "square.grid.2x2.fill",
                url: "https://share.google/lkShCeDOgzmzCdd7b"
            ),
        ]
    }

    private var supportDownloadStatus: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(
                    remote.isLoading ? remote.statusText : supportStatusMessage
                )
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

                Spacer()

                Text("\(Int(remote.progress * 100))%")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(gold)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(black.opacity(0.72))

                    Rectangle()
                        .fill(gold)
                        .frame(width: proxy.size.width * remote.progress)
                }
            }
            .frame(height: 12)
            .overlay(
                MontamCutRectangle(cut: 4)
                    .stroke(blue.opacity(0.75), lineWidth: 1.2)
            )
            .clipShape(MontamCutRectangle(cut: 4))

            HStack {
                Text("\(remote.completedItems) / \(remote.totalItems)")
                Spacer()
                Text(remote.formattedBytes(remote.downloadedBytes))
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)

            Text(
                "Aktualisieren lädt Manifest und JSON. Alles laden speichert Bilder und Musik lokal."
            )
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(MontamPalette.mutedText)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(panel.opacity(0.78))
        .overlay(
            MontamCutRectangle(cut: 12)
                .stroke(gold.opacity(0.82), lineWidth: 1.4)
        )
        .clipShape(MontamCutRectangle(cut: 12))
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(gold)
            .padding(.top, 4)
    }

    private func socialLinkButton(_ item: SocialLink) -> some View {
        Group {
            if let url = URL(string: item.url) {
                Link(destination: url) {
                    socialLinkLabel(item)
                }
            } else {
                socialLinkLabel(item)
                    .opacity(0.45)
            }
        }
    }

    private func socialLinkLabel(_ item: SocialLink) -> some View {
        HStack(spacing: 10) {
            Image(systemName: item.systemImage)
                .font(.system(size: 17, weight: .black))
                .frame(width: 22)

            Text(item.title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 0)
        }
        .foregroundStyle(black)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(gold)
        .overlay(
            MontamCutRectangle(cut: 8)
                .stroke(blue.opacity(0.85), lineWidth: 1.4)
        )
        .clipShape(MontamCutRectangle(cut: 8))
    }

    private struct SocialLink: Identifiable {
        let title: String
        let systemImage: String
        let url: String

        var id: String {
            title
        }
    }

    private func supportActionButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(black)
                .frame(maxWidth: .infinity)
                .frame(height: 78)
                .background(gold)
                .overlay(
                    MontamCutRectangle(cut: 10)
                        .stroke(gold, lineWidth: 1.6)
                )
                .clipShape(MontamCutRectangle(cut: 10))
        }
        .buttonStyle(.plain)
        .disabled(remote.isLoading)
        .opacity(remote.isLoading ? 0.45 : 1)
    }

    private func beginStartFlow() {
        guard !remote.isLoading, !isCheckingUpdate, !showSupportMenu else {
            return
        }

        isCheckingUpdate = true
        remote.checkForUpdate { hasUpdate in
            isCheckingUpdate = false
            if hasUpdate {
                showUpdateDialog = true
            } else {
                startPreloadThenGame()
            }
        }
    }

    private func startPreloadThenGame() {
        remote.preload {
            ServiceStatusManager.shared.refresh()
            if ServiceStatusManager.shared.activeMaintenance == nil {
                appModel.startGame()
            } else {
                appModel.appState = .maintenance
            }
        }
    }

    private func loadFeaturedCharacters() {
        guard featuredCharacters.isEmpty else { return }

        let characters =
            (try? JSONLoader.load("characters") as [Character])
            ?? []
        featuredCharacters = characters.filter { !$0.sprite.isEmpty }
        featuredIndex = 0
    }

    private func rotateFeaturedMontam() {
        guard !showSupportMenu, featuredCharacters.count > 1 else {
            return
        }

        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            featuredIndex = (featuredIndex + 1) % featuredCharacters.count
        }
    }
}

#Preview {
    StartView()
        .environmentObject(AppModel())
}
