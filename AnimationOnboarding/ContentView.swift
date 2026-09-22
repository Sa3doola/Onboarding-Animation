import SwiftUI

/// Demo host: shows onboarding on first launch and lets you replay it.
struct ContentView: View {
    @Environment(OnboardingStore.self) private var onboardingStore

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)

            Text("Welcome back")
                .font(.largeTitle.bold())

            if let result = onboardingStore.lastResult {
                Text("Last onboarding result: \(String(describing: result))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button("Replay Onboarding") {
                onboardingStore.reset()
            }
            .buttonStyle(.glassProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onboarding(store: onboardingStore, content: .mock)
    }
}

#Preview {
    ContentView()
        .environment(OnboardingStore(defaults: UserDefaults(suiteName: "preview")!))
}
