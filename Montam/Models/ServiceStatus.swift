//
//  ServiceStatus.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Foundation

struct ServiceStatusRoot: Codable {
    let maintenance: MaintenanceWindow?
    let announcements: [ServiceAnnouncement]
}

struct MaintenanceWindow: Codable, Identifiable, Hashable {
    let id: String
    let enabled: Bool
    let title: String
    let message: String
    let startDate: String?
    let endDate: String?
    let icon: String?

    var isActive: Bool {
        guard enabled else { return false }
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

struct ServiceAnnouncement: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let message: String
    let category: String
    let startDate: String?
    let endDate: String?
    let icon: String?

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

enum ServiceStatusLoader {
    static func load() -> ServiceStatusRoot {
        do {
            return try JSONLoader.load("service_status")
        } catch {
            print("service_status.json konnte nicht geladen werden:", error)
            return ServiceStatusRoot(maintenance: nil, announcements: [])
        }
    }
}
