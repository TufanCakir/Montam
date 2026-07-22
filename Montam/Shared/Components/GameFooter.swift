//
//  GameFooter.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct GameFooter: View {

    private let items: [(title: String, icon: String)] = [
        ("Zähmer", "tamer"),
        ("Montam", "montam"),
        ("Dungeon", "dungeon"),
        ("", "game"),
        ("Summon", "summon"),
        ("Erkunden", "explore"),
        ("Shop", "shop"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.06, blue: 0.2),
                    Color(red: 0.0, green: 0.14, blue: 0.42),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 3) {
                ForEach(0..<26, id: \.self) { _ in
                    Rectangle()
                        .fill(.cyan.opacity(0.28))
                        .frame(height: 1)
                }
            }

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) {
                    index,
                    item in
                    VStack(spacing: 2) {
                        GeneratedTabIcon(id: item.icon, isSelected: index == 3)
                            .padding(index == 3 ? 13 : 12)
                            .frame(
                                width: index == 3 ? 78 : 64,
                                height: index == 3 ? 78 : 60
                            )
                            .background(.blue.opacity(index == 3 ? 0.7 : 0.55))
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: index == 3 ? 39 : 10
                                )
                            )
                            .overlay(
                                RoundedRectangle(
                                    cornerRadius: index == 3 ? 39 : 10
                                ).stroke(.cyan.opacity(0.65), lineWidth: 2)
                            )
                            .shadow(
                                color: index == 3
                                    ? .purple.opacity(0.85)
                                    : .black.opacity(0.45),
                                radius: index == 3 ? 12 : 3
                            )

                        if !item.title.isEmpty {
                            Text(item.title)
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .heavy,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.cyan)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
    }
}
