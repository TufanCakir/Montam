//
//  EventManager.swift
//  Drakon
//
//  Created by Tufan Cakir on 23.05.26.
//

import Combine
import Foundation

class EventManager: ObservableObject {

    static let shared = EventManager()

    @Published var events: [GameEvent] = []
    @Published var categories: [EventCategoryInfo] = []

    func load() {
        do {
            let root: EventRoot = try JSONLoader.load("events")
            events = root.events
            categories = root.categories
            print("Loaded Events:", events.count)
        } catch {
            print(error)
        }
    }

    func crystalMultiplier() -> Double {

        activeEvents()
            .compactMap { $0.modifiers?.crystalMultiplier }
            .reduce(1.0, *)
    }

    func coinMultiplier() -> Double {

        activeEvents()
            .compactMap { $0.modifiers?.coinMultiplier }
            .reduce(1.0, *)
    }

    func title(for category: EventCategory) -> String {
        categories.first { $0.id == category.rawValue }?.title
            ?? category.rawValue.capitalized
    }

    private func seededShuffle(_ events: [GameEvent]) -> [GameEvent] {
        var generator = SeededGenerator(seed: currentRotationIndex())
        return events.shuffled(using: &generator)
    }

    struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: Int) {
            self.state = UInt64(seed)
        }

        mutating func next() -> UInt64 {
            state = 2_862_933_555_777_941_757 &* state &+ 3_037_000_493
            return state
        }
    }

    func events(for category: EventCategory, mode: EventMode) -> [GameEvent] {

        let filtered = activeEvents()
            .filter {
                $0.category == category && $0.mode == mode
            }

        let shuffled = seededShuffle(filtered)

        if category == .boss {
            let featured = shuffled.first
            let rest = Array(shuffled.dropFirst())

            return [featured].compactMap { $0 }
                + rotatedEvents(from: rest, count: 2)
        }

        return rotatedEvents(from: shuffled, count: 3)
    }

    func events(forCategoryId categoryId: String, mode: EventMode)
        -> [GameEvent]
    {
        guard let category = EventCategory(rawValue: categoryId) else {
            return []
        }

        return events(for: category, mode: mode)
    }

    var bossEvents: [GameEvent] {
        events(for: .boss, mode: .main)
    }

    var storyEvents: [GameEvent] {
        events(for: .story, mode: .main)
    }

    var specialEvents: [GameEvent] {
        events(for: .special, mode: .main)
    }

    var buffEvents: [GameEvent] {
        events(for: .buff, mode: .main)
    }

    func expMultiplier() -> Double {

        activeEvents()
            .compactMap {
                $0.modifiers?.expMultiplier
            }
            .reduce(1.0, *)
    }

    func activeEvents() -> [GameEvent] {
        let now = Date()

        return events.filter { event in
            if let startString = event.startDate,
                let endString = event.endDate
            {

                guard let start = DrakonDateParser.date(from: startString),
                    let end = DrakonDateParser.date(from: endString)
                else { return false }

                return now >= start && now <= end
            }

            // ❗ Alle ohne Datum sind grundsätzlich "pool events"
            return true
        }
    }

    private func currentRotationIndex() -> Int {
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)  // FIX GLOBAL START
        let days =
            Calendar.current.dateComponents([.day], from: startDate, to: Date())
            .day ?? 0
        return days / 7
    }

    private func rotatedEvents(from events: [GameEvent], count: Int = 3)
        -> [GameEvent]
    {
        guard !events.isEmpty else { return [] }

        let rotation = currentRotationIndex()
        let startIndex = (rotation * count) % events.count

        var result: [GameEvent] = []

        for i in 0..<min(count, events.count) {
            let index = (startIndex + i) % events.count
            result.append(events[index])
        }

        return result
    }
}
