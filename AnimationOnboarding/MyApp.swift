import SwiftUI

@main struct MyApp: App {
    /// Bump `version` to show onboarding again after an update.
    @State private var onboardingStore = OnboardingStore(version: 1)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(onboardingStore)
        }

        #if os(macOS)
        OnboardingWindow(store: onboardingStore, items: OnboardingContent.mock.mac)
        #endif
    }
}
