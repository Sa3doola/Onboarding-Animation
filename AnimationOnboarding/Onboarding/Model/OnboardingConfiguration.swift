//
//  OnboardingConfiguration.swift
//  AnimationOnboarding
//

import SwiftUI

/// Appearance and behavior shared by every onboarding layout.
///
/// Inject it with `.onboardingConfiguration(_:)` anywhere above the onboarding view.
struct OnboardingConfiguration {
    // MARK: Colors
    var tint: Color = .blue
    var buttonForeground: Color = .white
    var textColor: Color = .primary

    // MARK: Copy
    var continueTitle: LocalizedStringResource = "Continue"
    var getStartedTitle: LocalizedStringResource = "Get Started"
    var skipTitle: LocalizedStringResource = "Skip"

    // MARK: Behavior
    /// Shows a "Skip" button on every page except the last.
    var allowsSkip: Bool = true
    /// Shows a close button on the first page. Keep it off for a mandatory first-run flow.
    var allowsDismiss: Bool = false
    /// Lets the user swipe between pages.
    var allowsSwipe: Bool = true
    var hapticsEnabled: Bool = true

    // MARK: Motion
    /// Page changes (screenshot slide, text, indicator).
    var animation: Animation = .interpolatingSpring(duration: 0.64, bounce: 0)
    /// Device zoom. Slightly slower than `animation` so the zoom settles just after the
    /// page slides in, which reads as a camera move instead of a jump.
    var zoomAnimation: Animation = .smooth(duration: 0.9, extraBounce: 0.04)

    // MARK: Device mockup
    /// Screen aspect ratios (width / height) used for the device mockups. Match them to
    /// your screenshots so nothing gets cropped.
    var phoneScreenAspectRatio: CGFloat = 1206 / 2622   // iPhone 17 / 16 Pro
    var padScreenAspectRatio: CGFloat = 2064 / 2752     // iPad Pro 13" portrait
    var macScreenAspectRatio: CGFloat = 1512 / 977      // MacBook Air 13"

    static let `default` = OnboardingConfiguration()
}

extension EnvironmentValues {
    @Entry var onboardingConfiguration: OnboardingConfiguration = .default
}

extension View {
    func onboardingConfiguration(_ configuration: OnboardingConfiguration) -> some View {
        environment(\.onboardingConfiguration, configuration)
    }
}
