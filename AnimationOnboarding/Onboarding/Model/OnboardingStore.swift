//
//  OnboardingStore.swift
//  AnimationOnboarding
//

import SwiftUI

/// Remembers which onboarding version the user has already seen.
///
/// Bump `version` when you ship a new onboarding (e.g. a "What's New" flow) and it will be
/// presented again to users who only saw an older one.
@Observable
final class OnboardingStore {
    let version: Int
    private let key: String
    private let defaults: UserDefaults

    private(set) var seenVersion: Int
    private(set) var lastResult: OnboardingResult?

    init(version: Int = 1, key: String = "onboarding.seenVersion", defaults: UserDefaults = .standard) {
        self.version = version
        self.key = key
        self.defaults = defaults
        self.seenVersion = defaults.integer(forKey: key)
    }

    var needsOnboarding: Bool { seenVersion < version }

    func finish(with result: OnboardingResult) {
        lastResult = result
        seenVersion = version
        defaults.set(version, forKey: key)
    }

    /// Shows onboarding again (e.g. from a "Replay tutorial" setting).
    func reset() {
        lastResult = nil
        seenVersion = 0
        defaults.removeObject(forKey: key)
    }
}
