//
//  NetworkMonitor.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Network
import SwiftUI

final class NetworkMonitor: ObservableObject {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true
    @Published var isChecking: Bool = false  // ⭐ NEU

    private init() {

        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("🌐 Internet:", self?.isConnected ?? false)
            }
        }

        monitor.start(queue: queue)
    }

    // ⭐ Manuelle Prüfung (für Button)
    func checkConnection() {
        isChecking = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isChecking = false
        }
    }
}
