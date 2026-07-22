import Foundation

struct AppSocialLink: Identifiable {
    let id: String
    let title: String
    let url: URL

    static let all: [AppSocialLink] = [
        AppSocialLink(id: "youtube", title: "YouTube", url: URL(string: "https://www.youtube.com/@TufanCakirOfficial")!),
        AppSocialLink(id: "instagram", title: "Instagram", url: URL(string: "https://www.instagram.com/tufancakirofficial?igsh=MXg1dnUwajFrZTJmdA%3D%3D&utm_source=qr")!),
        AppSocialLink(id: "x", title: "X", url: URL(string: "https://x.com/tufan_cakir_?s=11")!),
        AppSocialLink(id: "facebook", title: "Facebook", url: URL(string: "https://www.facebook.com/share/19CNEBZQBP/?mibextid=wwXIfr")!),
        AppSocialLink(id: "tiktok", title: "TikTok", url: URL(string: "https://www.tiktok.com/@tufanwhiteandblack?_r=1&_t=ZG-98FOHBCYfrM")!),
        AppSocialLink(id: "threads", title: "Threads", url: URL(string: "https://www.threads.com/@tufan_cakir_?igshid=NTc4MTIwNjQ2YQ==")!),
        AppSocialLink(id: "github", title: "GitHub", url: URL(string: "https://github.com/TufanCakir")!),
        AppSocialLink(id: "discord", title: "Discord", url: URL(string: "https://discord.gg/z9qpMgdAj")!),
        AppSocialLink(id: "linkedin", title: "LinkedIn", url: URL(string: "https://www.linkedin.com/in/tufan-cakir?utm_source=share_via&utm_content=profile&utm_medium=member_ios")!)
    ]
}
