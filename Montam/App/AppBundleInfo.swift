//
//  AppBundleInfo.swift
//  Montam
//
//  Created by Tufan Cakir on 21.07.26.
//

import Foundation

enum AppBundleInfo {
    static var appVersion: String {
        infoValue("CFBundleShortVersionString") ?? "0"
    }

    static var versionDisplay: String {
        let version = infoValue("CFBundleShortVersionString")
        let build = infoValue("CFBundleVersion")

        switch (version, build) {
        case (let version?, let build?)
        where !version.isEmpty && !build.isEmpty:
            return "v\(version) (\(build))"
        case (let version?, _) where !version.isEmpty:
            return "v\(version)"
        case (_, let build?) where !build.isEmpty:
            return "Build \(build)"
        default:
            return "Version unbekannt"
        }
    }

    private static func infoValue(_ key: String) -> String? {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: key)
                as? String,
            !value.isEmpty
        else {
            return nil
        }

        return value
    }
}
