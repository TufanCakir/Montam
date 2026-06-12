//
//  NewsView.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import SwiftUI

struct NewsView: View {
    @ObservedObject private var service = ServiceStatusManager.shared
    @State private var news: [NewsItem] = []
    @State private var selectedCategory = "all"

    private var categories: [String] {
        ["all"] + Array(Set(news.map(\.category))).sorted()
    }

    private var visibleNews: [NewsItem] {
        selectedCategory == "all"
            ? news
            : news.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 14) {
            categoryBar

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(service.activeAnnouncements) { announcement in
                        announcementCard(announcement)
                    }

                    if visibleNews.isEmpty {
                        emptyState
                    } else {
                        ForEach(visibleNews) { item in
                            newsCard(item)
                        }
                    }
                }
                .padding(18)
                .padding(.bottom, 24)
            }
        }
        .background(MontamScreenBackground())
        .navigationTitle("News")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            service.refresh()
            news = NewsLoader.load()
            selectedCategory = categories.first ?? "all"
        }
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    let selected = selectedCategory == category

                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category.uppercased())
                            .font(
                                .system(
                                    size: 11,
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                selected ? MontamPalette.black : .white
                            )
                            .padding(.horizontal, 16)
                            .frame(height: 38)
                            .background(
                                selected
                                    ? MontamPalette.gold
                                    : MontamPalette.panel
                            )
                            .clipShape(
                                MontamEggShape()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            RemoteAssetImage(name: "montam_icon")
                .scaledToFit()
                .frame(width: 78, height: 78)
                .opacity(0.7)

            Text("KEINE NEWS")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 90)
    }

    private func announcementCard(_ item: ServiceAnnouncement) -> some View {
        contentCard(
            title: item.title,
            body: item.message,
            category: item.category,
            icon: item.icon ?? "montam_icon",
            featured: true,
            endDate: item.endDate
        )
    }

    private func newsCard(_ item: NewsItem) -> some View {
        contentCard(
            title: item.title,
            body: item.body,
            category: item.category,
            icon: item.icon ?? "montam_icon",
            featured: item.featured ?? false,
            endDate: item.endDate
        )
    }

    private func contentCard(
        title: String,
        body: String,
        category: String,
        icon: String,
        featured: Bool,
        endDate: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                RemoteAssetImage(name: icon)
                    .scaledToFit()
                    .frame(width: 68, height: 68)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        badge(
                            category.uppercased(),
                            tint: MontamPalette.blue
                        )
                        if featured {
                            badge("FEATURED", tint: MontamPalette.gold)
                        }
                    }

                    Text(title.uppercased())
                        .font(
                            .system(size: 17, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }

            Text(body)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(MontamPalette.mutedText)

            if let endDate {
                Text("BIS \(endDate)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(MontamPalette.gold)
            }
        }
        .padding(16)
        .background(MontamPalette.panel)
        .clipShape(MontamEggShape())
        .overlay(
            MontamEggShape()
                .stroke(
                    featured
                        ? MontamPalette.gold : MontamPalette.blue,
                    lineWidth: featured ? 2 : 1.5
                )
        )
    }

    private func badge(_ title: String, tint: Color) -> some View {
        Text(title)
            .font(.system(size: 8, weight: .black, design: .rounded))
            .foregroundStyle(tint == MontamPalette.gold ? .black : .white)
            .padding(.horizontal, 7)
            .frame(height: 20)
            .background(tint)
            .clipShape(MontamEggShape())
    }
}

#Preview {
    NewsView()
}
