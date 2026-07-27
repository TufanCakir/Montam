//
//  AppSocialLink.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import Foundation

struct AppSocialLink: Identifiable {
    let id: String
    let title: String
    let url: URL

    static let all: [AppSocialLink] = definitions.compactMap {
        AppSocialLink(id: $0.id, title: $0.title, urlString: $0.urlString)
    }

    private static let definitions:
        [(id: String, title: String, urlString: String)] = [
            (
                id: "youtube",
                title: "YouTube",
                urlString: "https://www.youtube.com/@TufanCakirOfficial"
            ),
            (
                id: "instagram",
                title: "Instagram",
                urlString:
                    "https://www.instagram.com/tufancakirofficial?igsh=MXg1dnUwajFrZTJmdA%3D%3D&utm_source=qr"
            ),
            (
                id: "x",
                title: "X",
                urlString: "https://x.com/tufan_cakir_?s=11"
            ),
            (
                id: "facebook",
                title: "Facebook",
                urlString:
                    "https://www.facebook.com/share/19CNEBZQBP/?mibextid=wwXIfr"
            ),
            (
                id: "tiktok",
                title: "TikTok",
                urlString:
                    "https://www.tiktok.com/@tufanwhiteandblack?_r=1&_t=ZG-98FOHBCYfrM"
            ),
            (
                id: "threads",
                title: "Threads",
                urlString:
                    "https://www.threads.com/@tufan_cakir_?igshid=NTc4MTIwNjQ2YQ=="
            ),
            (
                id: "github",
                title: "GitHub",
                urlString: "https://github.com/TufanCakir"
            ),
            (
                id: "discord",
                title: "Discord",
                urlString: "https://discord.gg/z9qpMgdAj"
            ),
            (
                id: "linkedin",
                title: "LinkedIn",
                urlString:
                    "https://www.linkedin.com/in/tufan-cakir?utm_source=share_via&utm_content=profile&utm_medium=member_ios"
            ),
        ]

    private init?(id: String, title: String, urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }

        self.id = id
        self.title = title
        self.url = url
    }
}
