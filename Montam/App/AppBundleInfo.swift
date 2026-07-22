//
//  AppBundleInfo.swift
//  Monster Transorfmieren
//
//  Created by Tufan Cakir on 21.07.26.
//

import Foundation

enum AppBundleInfo {
    static var versionDisplay: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?) where !version.isEmpty && !build.isEmpty:
            return "v\(version) (\(build))"
        case let (version?, _) where !version.isEmpty:
            return "v\(version)"
        case let (_, build?) where !build.isEmpty:
            return "Build \(build)"
        default:
            return "Version unbekannt"
        }
    }
}

