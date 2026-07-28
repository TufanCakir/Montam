//
//  AppLocalizationService.swift
//  Montam
//
//  Created by Tufan Cakir on 28.07.26.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case german = "de"
    case english = "en"

    var id: String { rawValue }

    var localizationFileName: String {
        switch self {
        case .german: "localization_de"
        case .english: "localization_en"
        }
    }

    var titleKey: String {
        switch self {
        case .german: "app.language.german"
        case .english: "app.language.english"
        }
    }
}

enum AppLocalizationService {
    static let languageKey = "settings.language"
    static let fallbackLanguage = AppLanguage.german

    static var selectedLanguage: AppLanguage {
        let rawValue = UserDefaults.standard.string(forKey: languageKey)
        return rawValue.flatMap(AppLanguage.init(rawValue:)) ?? fallbackLanguage
    }

    static func text(_ key: String) -> String {
        let selected = selectedLanguage
        if let value = localizedValue(key, language: selected) {
            return value
        }

        if selected != fallbackLanguage,
            let fallback = localizedValue(key, language: fallbackLanguage)
        {
            return fallback
        }

        return key
    }

    static func text(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), arguments: arguments)
    }

    private static func localizedValue(
        _ key: String,
        language: AppLanguage
    ) -> String? {
        let values = localizationValues(for: language)
        return values[key]
    }

    private static func localizationValues(
        for language: AppLanguage
    ) -> [String: String] {
        var values = bundledLocalizationValues(for: language)

        if let remoteValues = cachedLocalizationValues(for: language) {
            values.merge(remoteValues) { _, remote in remote }
        }

        return values
    }

    private static func bundledLocalizationValues(
        for language: AppLanguage
    ) -> [String: String] {
        bundledValuesByLanguage[language] ?? [:]
    }

    private static func cachedLocalizationValues(
        for language: AppLanguage
    ) -> [String: String]? {
        let url = RemoteContentService.cachedJSONURL(
            for: language.localizationFileName
        )
        guard FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }

        return JSONDataLoader.load(
            language.localizationFileName,
            as: [String: String].self
        )
    }

    private static let bundledValuesByLanguage:
        [AppLanguage: [String: String]] =
            Dictionary(
                uniqueKeysWithValues: AppLanguage.allCases.map { language in
                    let values: [String: String]
                    if let url = Bundle.main.url(
                        forResource: language.localizationFileName,
                        withExtension: "json"
                    ),
                        let data = try? Data(contentsOf: url),
                        let decoded = try? JSONDecoder().decode(
                            [String: String].self,
                            from: data
                        )
                    {
                        values = decoded
                    } else {
                        values = [:]
                    }

                    return (language, values)
                }
            )
}
