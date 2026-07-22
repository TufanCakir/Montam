import SwiftUI

struct AppScreenBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.0, green: 0.06, blue: 0.2),
                Color(red: 0.0, green: 0.14, blue: 0.42),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .top) {
            AppScreenLinePattern()
                .opacity(0.42)
        }
    }
}

private struct AppScreenLinePattern: View {
    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<80, id: \.self) { _ in
                Rectangle()
                    .fill(.cyan.opacity(0.22))
                    .frame(height: 1)
            }
        }
    }
}
