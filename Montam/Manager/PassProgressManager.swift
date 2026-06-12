//
//  PassProgressManager.swift
//  Montam
//
//  Created by Tufan Cakir on 11.06.26.
//

import Combine
import Foundation

final class PassProgressManager: ObservableObject {
    static let shared = PassProgressManager()

    @Published private(set) var pointsByPass: [String: Int] = [:]
    @Published private(set) var claimedRewardIds: Set<String> = []

    private let pointsKey = "montam_pass_points_by_pass"
    private let claimedKey = "montam_pass_claimed"

    private init() {
        pointsByPass =
            UserDefaults.standard.dictionary(forKey: pointsKey)
            as? [String: Int]
            ?? [:]
        claimedRewardIds = Set(
            UserDefaults.standard.stringArray(forKey: claimedKey) ?? []
        )
    }

    func addPoints(_ amount: Int, passId: String = "feralpass_s1") {
        pointsByPass[passId, default: 0] += max(0, amount)
        save()
    }

    func addPointsToAllPasses(_ amount: Int) {
        let passIds = PassLoader.loadAll().map(\.id)
        let targets = passIds.isEmpty ? ["feralpass_s1"] : passIds
        for passId in targets {
            pointsByPass[passId, default: 0] += max(0, amount)
        }
        save()
    }

    func points(for passId: String) -> Int {
        pointsByPass[passId] ?? 0
    }

    func canClaim(
        passId: String,
        tier: Int,
        pointsPerTier: Int,
        lane: String
    ) -> Bool {
        points(for: passId) >= tier * pointsPerTier
            && !isClaimed(passId: passId, tier: tier, lane: lane)
    }

    func isClaimed(passId: String, tier: Int, lane: String) -> Bool {
        claimedRewardIds.contains(
            rewardId(passId: passId, tier: tier, lane: lane)
        )
    }

    func claim(passId: String, tier: Int, lane: String) {
        claimedRewardIds.insert(
            rewardId(passId: passId, tier: tier, lane: lane)
        )
        save()
    }

    func reset() {
        pointsByPass = [:]
        claimedRewardIds.removeAll()
        save()
    }

    private func rewardId(passId: String, tier: Int, lane: String) -> String {
        "\(passId)_\(lane)_\(tier)"
    }

    private func save() {
        UserDefaults.standard.set(pointsByPass, forKey: pointsKey)
        UserDefaults.standard.set(Array(claimedRewardIds), forKey: claimedKey)
    }
}
