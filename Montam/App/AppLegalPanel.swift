//
//  AppLegalPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 28.07.26.
//

import SwiftUI

struct AppLegalPanel: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(AppLocalizationService.languageKey) private
        var languageRawValue =
        AppLocalizationService.fallbackLanguage.rawValue
    let onClose: () -> Void

    private let legalLinks: [AppLegalLink] = [
        AppLegalLink(
            titleKey: "legal.privacy",
            icon: "hand.raised.fill",
            urlString: "https://montamprivacypolicy.tufancakir.com"
        ),
        AppLegalLink(
            titleKey: "legal.eula",
            icon: "doc.plaintext.fill",
            urlString:
                "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        ),
        AppLegalLink(
            titleKey: "legal.terms",
            icon: "checkmark.shield.fill",
            urlString: "https://montamprivacypolicy.tufancakir.com"
        ),
        AppLegalLink(
            titleKey: "legal.support",
            icon: "questionmark.circle.fill",
            urlString: "https://montamprivacypolicy.tufancakir.com"
        ),
    ].compactMap { $0 }

    var body: some View {
        VStack(spacing: 0) {
            GamePanelHeader(
                title: AppLocalizationService.text("start.legal"),
                onClose: onClose
            )
            .overlay(AppLegalSquarePattern().opacity(0.22))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(AppLocalizationService.text("legal.message"))
                        .font(
                            .system(size: 13, weight: .bold, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                        ],
                        spacing: 10
                    ) {
                        ForEach(legalLinks) { link in
                            AppLegalLinkButton(
                                title: AppLocalizationService.text(
                                    link.titleKey
                                ),
                                icon: link.icon
                            ) {
                                openURL(link.url)
                            }
                        }
                    }

                    Text(AppLocalizationService.text("start.social"))
                        .font(
                            .system(size: 17, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan)
                        .padding(.top, 6)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                        ],
                        spacing: 10
                    ) {
                        ForEach(AppSocialLink.all) { link in
                            AppLegalLinkButton(
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
}

private struct AppLegalSquarePattern: View {
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

private struct AppLegalLinkButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(.blue.opacity(0.42))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(
                        .cyan.opacity(0.35),
                        lineWidth: 1
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

private struct AppLegalLink: Identifiable {
    let id = UUID()
    let titleKey: String
    let icon: String
    let url: URL

    init?(titleKey: String, icon: String, urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }

        self.titleKey = titleKey
        self.icon = icon
        self.url = url
    }
}
