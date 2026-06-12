//
//  NewsConfig.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct NewsRoot: Codable {
    let news: [NewsItem]
}

struct NewsItem: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let category: String
    let icon: String?
    let startDate: String?
    let endDate: String?
    let featured: Bool?

    var isActive: Bool {
        let now = Date()

        if let start = MontamDateParser.date(from: startDate), now < start {
            return false
        }

        if let end = MontamDateParser.date(from: endDate), now > end {
            return false
        }

        return true
    }
}

enum NewsLoader {
    static func load() -> [NewsItem] {
        let manualNews: [NewsItem]

        do {
            let root: NewsRoot = try JSONLoader.load("news")
            manualNews = root.news
        } catch {
            print("news.json konnte nicht geladen werden:", error)
            manualNews = []
        }

        return (manualNews + generatedNews())
            .reduce(into: [String: NewsItem]()) { result, item in
                result[item.id] = item
            }
            .values
            .filter(\.isActive)
            .sorted {
                if ($0.featured ?? false) != ($1.featured ?? false) {
                    return ($0.featured ?? false) && !($1.featured ?? false)
                }

                return $0.title < $1.title
            }
    }

    private static func generatedNews() -> [NewsItem] {
        var items: [NewsItem] = []

        items.append(contentsOf: eventNews())
        items.append(contentsOf: summonNews())
        items.append(contentsOf: passNews())
        items.append(contentsOf: eggNews())
        items.append(contentsOf: skinNews())
        items.append(contentsOf: storyNews())

        return items
    }

    private static func eventNews() -> [NewsItem] {
        guard let root: EventRoot = try? JSONLoader.load("events") else {
            return []
        }

        return root.events.map { event in
            NewsItem(
                id: "auto_event_\(event.id)",
                title: event.title,
                body: event.description
                    ?? event.storyText
                    ?? "Neues Event ist verfuegbar.",
                category: "event",
                icon: event.icon,
                startDate: event.startDate,
                endDate: event.endDate,
                featured: false
            )
        }
    }

    private static func summonNews() -> [NewsItem] {
        guard let root: SummonRoot = try? JSONLoader.load("summons") else {
            return []
        }

        return root.banners.map { banner in
            NewsItem(
                id: "auto_summon_\(banner.id)",
                title: banner.title,
                body:
                    "Summon Banner mit \(banner.pool.count) Montams im Pool und \(banner.currency.uppercased()) als Waehrung.",
                category: "summon",
                icon: banner.bannerImage,
                startDate: nil,
                endDate: nil,
                featured: false
            )
        }
    }

    private static func passNews() -> [NewsItem] {
        PassLoader.loadAll().map { pass in
            NewsItem(
                id: "auto_pass_\(pass.id)",
                title: pass.title,
                body:
                    "\(pass.tiers.count) Tiers mit Free und Premium Rewards sind aktiv.",
                category: "pass",
                icon: pass.icon,
                startDate: nil,
                endDate: nil,
                featured: false
            )
        }
    }

    private static func eggNews() -> [NewsItem] {
        EggConfigLoader.load().eggs.map { egg in
            NewsItem(
                id: "auto_egg_\(egg.id)",
                title: egg.title,
                body: egg.description
                    ?? "Dieses Ei kann einen Feral Montam ausbrueten.",
                category: "egg",
                icon: egg.eggImage,
                startDate: egg.startDate,
                endDate: egg.endDate,
                featured: egg.isLimited ?? false
            )
        }
    }

    private static func skinNews() -> [NewsItem] {
        SkinConfigLoader.load().skins.map { skin in
            NewsItem(
                id: "auto_skin_\(skin.id)",
                title: skin.title,
                body: skin.description ?? "Neuer Montam Skin verfuegbar.",
                category: "skin",
                icon: skin.image,
                startDate: skin.startDate,
                endDate: skin.endDate,
                featured: skin.isEventLimited ?? false
            )
        }
    }

    private static func storyNews() -> [NewsItem] {
        GameConfigManager.shared.config.storyChapters.map { chapter in
            NewsItem(
                id: "auto_story_\(chapter.id)",
                title: chapter.title,
                body: chapter.description,
                category: "story",
                icon: chapter.icon,
                startDate: nil,
                endDate: nil,
                featured: false
            )
        }
    }
}
