//
//  PurchaseNoticeView.swift
//  Montam
//
//  Created by Tufan Cakir on 28.07.26.
//

import SwiftUI

struct PurchaseNoticeView: View {
    let onContinue: () -> Void

    @AppStorage(AppLocalizationService.languageKey) private
        var languageRawValue =
        AppLocalizationService.fallbackLanguage.rawValue

    var body: some View {
        ZStack {
            AppScreenBackground()

            VStack(spacing: 22) {
                Text(AppLocalizationService.text("purchaseNotice.title"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.75), radius: 2, y: 1)

                Text(AppLocalizationService.text("purchaseNotice.message"))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.cyan)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.65), radius: 2, y: 1)

                Button(action: onContinue) {
                    Text(AppLocalizationService.text("common.ok"))
                        .font(
                            .system(size: 18, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.blue.opacity(0.72))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.cyan.opacity(0.8), lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                languageToggle
            }
            .padding(22)
            .frame(maxWidth: 360)
        }
        .ignoresSafeArea()
    }

    private var languageToggle: some View {
        HStack(spacing: 8) {
            languageButton(.german)
            languageButton(.english)
        }
        .padding(4)
        .background(Color.black.opacity(0.34))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.cyan.opacity(0.45), lineWidth: 1)
        )
    }

    private func languageButton(_ language: AppLanguage) -> some View {
        let isSelected = languageRawValue == language.rawValue

        return Button {
            languageRawValue = language.rawValue
        } label: {
            Text(language.rawValue.uppercased())
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(isSelected ? .black : .white)
                .frame(width: 82, height: 38)
                .background(isSelected ? Color.cyan : Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PurchaseNoticeView {}
}
