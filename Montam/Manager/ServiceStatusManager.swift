//
//  ServiceStatusManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class ServiceStatusManager: ObservableObject {
    static let shared = ServiceStatusManager()

    @Published private(set) var status = ServiceStatusRoot(
        maintenance: nil,
        announcements: []
    )

    private init() {}

    func refresh() {
        status = ServiceStatusLoader.load()
    }

    var activeMaintenance: MaintenanceWindow? {
        status.maintenance?.isActive == true ? status.maintenance : nil
    }

    var activeAnnouncements: [ServiceAnnouncement] {
        status.announcements.filter(\.isActive)
    }
}
