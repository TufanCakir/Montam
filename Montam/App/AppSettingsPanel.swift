import SwiftData
import SwiftUI

struct AppSettingsPanel: View {
    let onClose: () -> Void
    let onDataDeleted: () -> Void

    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppSettingsService.musicEnabledKey) private var isMusicEnabled = true
    @State private var isConfirmingDelete = false
    @State private var message: String?

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: 16) {
                Toggle(isOn: $isMusicEnabled) {
                    Label("Musik", systemImage: isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                }
                .toggleStyle(.switch)
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(Color.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                settingsButton(title: "Cache leeren", icon: "trash.fill") {
                    AppSettingsService.clearCache()
                    showMessage("Cache geleert.")
                }

                settingsButton(title: "Benutzerdaten löschen", icon: "exclamationmark.triangle.fill", role: .destructive) {
                    isConfirmingDelete = true
                }

                if let message {
                    Text(message)
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(.cyan)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(22)
            .background(Color(red: 0.04, green: 0.16, blue: 0.34))
        }
        .frame(width: 350)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.cyan.opacity(0.9), lineWidth: 3))
        .confirmationDialog(
            "Alle Spieldaten löschen?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Alles löschen", role: .destructive) {
                AppSettingsService.deleteUserData(modelContext: modelContext)
                onDataDeleted()
            }

            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dein Spielstand, Monster und Tamer werden vollständig entfernt.")
        }
    }

    private var header: some View {
        HStack {
            Text("Einstellungen")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .background(
            LinearGradient(colors: [.blue, .cyan.opacity(0.78)], startPoint: .leading, endPoint: .trailing)
        )
    }

    private func settingsButton(
        title: String,
        icon: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 19, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(role == .destructive ? Color.red.opacity(0.78) : Color.cyan.opacity(0.88))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.black.opacity(0.7), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func showMessage(_ text: String) {
        message = text

        Task {
            try? await Task.sleep(for: .seconds(1.4))
            if message == text {
                message = nil
            }
        }
    }
}
