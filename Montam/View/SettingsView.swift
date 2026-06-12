//
//  SettingsView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    @State private var musicEnabled = !MusicManager.shared.isMuted
    @State private var volume = Double(MusicManager.shared.volume)
    @State private var showConfirm = false

    private let black = Color(red: 0.018, green: 0.018, blue: 0.022)
    private let panel = Color(red: 0.055, green: 0.058, blue: 0.068)
    private let gold = Color(red: 0.95, green: 0.72, blue: 0.18)
    private let blue = Color(red: 0.08, green: 0.24, blue: 0.62)
    private let mutedText = Color.white.opacity(0.62)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                accountSection
                audioSection
                infoSection
                dangerSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Account zurücksetzen?", isPresented: $showConfirm) {
            Button("Abbrechen", role: .cancel) {}
            Button("Alles löschen", role: .destructive) {
                appModel.fullReset()
            }
        } message: {
            Text(
                "Alle Montams, MontamCoins, Saphirs, Upgrades und Fortschritte werden gelöscht."
            )
        }
    }

    private var background: some View {
        black
            .overlay(alignment: .topTrailing) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 230, height: 230)
                    .opacity(0.055)
                    .offset(x: 60, y: -40)
            }
            .overlay(alignment: .bottomLeading) {
                RemoteAssetImage(name: "montam_icon")
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .opacity(0.045)
                    .offset(x: -90, y: 80)
            }
            .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 10) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 82, height: 82)

            Text("SETTINGS")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Montam account and game options")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var accountSection: some View {
        settingsCard(title: "Account", tint: gold) {
            settingsRow(
                image: "montam_icon",
                title: "Level",
                value: "\(PlayerProgressManager.shared.level)"
            )

            settingsRow(
                image: "skin_pyro_feral_default",
                title: "MontamCoins",
                value: MontamCoinsManager.shared.montamCoins.formatted()
            )

            settingsRow(
                image: "skin_blazion_tamed_default",
                title: "Saphirs",
                value: MontamSaphirsManager.shared.montamSaphirs.formatted()
            )

            settingsRow(
                image: "skin_infernon_mastered_default",
                title: "Team Size",
                value:
                    "\(GameConfigManager.shared.config.team.maxActiveTeamSize)"
            )
        }
    }

    private var audioSection: some View {
        settingsCard(title: "Audio", tint: blue) {
            bladeToggleRow(
                image: "montam_icon",
                title: "Music",
                isOn: $musicEnabled
            ) { enabled in
                if enabled == MusicManager.shared.isMuted {
                    MusicManager.shared.toggleMute()
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    RemoteAssetImage(name: "skin_blazion_tamed_default")
                        .scaledToFit()
                        .frame(width: 30, height: 30)

                    Text("Volume")
                        .font(
                            .system(size: 15, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(Int(volume * 100))%")
                        .font(
                            .system(size: 13, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(gold)
                }

                Slider(value: $volume, in: 0...1) { editing in
                    if !editing {
                        MusicManager.shared.setVolume(Float(volume))
                    }
                }
                .tint(gold)
                .onChange(of: volume) { _, newValue in
                    MusicManager.shared.setVolume(Float(newValue))
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var infoSection: some View {
        settingsCard(title: "Info", tint: gold) {
            settingsRow(
                image: "montam_icon",
                title: "App Version",
                value: appVersion
            )
            settingsRow(
                image: "skin_solarion_exalted_default",
                title: "Build",
                value: buildNumber
            )
            settingsRow(
                image: "skin_pyro_feral_default",
                title: "iOS",
                value: UIDevice.current.systemVersion
            )
        }
    }

    private var dangerSection: some View {
        settingsCard(title: "Reset", tint: .red) {
            Text(
                "Reset deletes all account progress and sends you back to starter selection."
            )
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(mutedText)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                showConfirm = true
            } label: {
                ZStack(alignment: .leading) {
                    SettingsBladeShape(pointDepth: 28, slant: 12)
                        .fill(Color.red.opacity(0.86))

                    HStack(spacing: 12) {
                        RemoteAssetImage(name: "skin_solarion_exalted_default")
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text("Account Reset")
                            .font(
                                .system(
                                    .headline,
                                    design: .rounded,
                                    weight: .black
                                )
                            )
                            .foregroundStyle(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 58)
            }
            .buttonStyle(.plain)
        }
    }

    private func settingsCard<Content: View>(
        title: String,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(tint)
                    .frame(width: 34, height: 3)

                Text(title.uppercased())
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(tint)
            }

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(panel)
        .overlay(
            SettingsAngledRectangle(cut: 16)
                .stroke(tint, lineWidth: 1.8)
        )
        .clipShape(SettingsAngledRectangle(cut: 16))
    }

    private func settingsRow(image: String, title: String, value: String)
        -> some View
    {
        HStack(spacing: 12) {
            RemoteAssetImage(name: image)
                .scaledToFit()
                .frame(width: 30, height: 30)

            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.vertical, 4)
    }

    private func bladeToggleRow(
        image: String,
        title: String,
        isOn: Binding<Bool>,
        onChange: @escaping (Bool) -> Void
    ) -> some View {
        HStack(spacing: 12) {
            RemoteAssetImage(name: image)
                .scaledToFit()
                .frame(width: 30, height: 30)

            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(gold)
                .onChange(of: isOn.wrappedValue) { _, newValue in
                    onChange(newValue)
                }
        }
        .padding(.vertical, 4)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

private struct SettingsBladeShape: Shape {
    let pointDepth: CGFloat
    let slant: CGFloat

    func path(in rect: CGRect) -> Path {
        let pointDepth = min(pointDepth, rect.width * 0.22)
        let slant = min(slant, rect.height * 0.38)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - pointDepth, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + slant, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct SettingsAngledRectangle: Shape {
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

#Preview {
    SettingsView()
        .environmentObject(AppModel())
}
