//
//  NewsPanel.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct NewsPanel: View {
    let onClose: () -> Void

    private let news = JSONDataLoader.load("news", as: [NewsData].self) ?? []

    var body: some View {
        VStack(spacing: 0) {
            header

            if news.isEmpty {
                emptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(news) { item in
                            NewsCard(item: item)
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: 480)
                .gamePanelBodyBackground()
            }
        }
        .gamePanelFrame()
    }

    private var header: some View {
        GamePanelHeader(title: "News", onClose: onClose)
    }

    private var emptyState: some View {
        GamePanelEmptyState(title: "Aktuell gibt es keine Neuigkeiten.")
    }
}

private struct NewsCard: View {
    let item: NewsData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                if let category = item.category {
                    Text(category.uppercased())
                        .font(
                            .system(size: 11, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .frame(height: 22)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                }

                if let date = item.date {
                    Text(date)
                        .font(
                            .system(size: 12, weight: .heavy, design: .rounded)
                        )
                        .foregroundStyle(.cyan.opacity(0.86))
                }
            }

            Text(item.title)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(item.message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.cyan.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(
                .cyan.opacity(0.42),
                lineWidth: 1
            )
        )
    }
}
