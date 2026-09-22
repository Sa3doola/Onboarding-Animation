//
//  OnboardingItem+Mock.swift
//  AnimationOnboarding
//
//  Real screenshots of Noor (ThawabForGod) on each platform, used by previews and the
//  demo app. Replace with your own pages.
//
//  Zoom anchors are unit points on the screenshot:
//  - iPhone / Mac scale the whole device, so the anchor is the point that stays put while
//    everything else grows away from it. `y` slightly below 0 keeps the top of the device
//    from sliding under the window edge.
//  - iPad zooms inside the screen, so anchors are clamped to 0...1.
//

import SwiftUI

extension OnboardingItem {
    /// iPhone 17 simulator, 1206 × 2622.
    static let mockPhone: [OnboardingItem] = [
        .init(
            id: "phone.prayerTimes",
            title: "Never Miss a Prayer",
            subtitle: "Today's prayer times with a live countdown to the next one.",
            screenshot: Image(.onboardingPhoneHome)
        ),
        .init(
            id: "phone.quran",
            title: "The Complete Quran",
            subtitle: "Browse all 114 surahs by name, juz, or your own bookmarks.",
            screenshot: Image(.onboardingPhoneQuran),
            // Surah list header and first cards.
            zoom: .init(scale: 1.3, anchor: .init(x: 0.5, y: -0.02))
        ),
        .init(
            id: "phone.adhkar",
            title: "Adhkar for Every Moment",
            subtitle: "Morning, evening, sleep and more, in one searchable list.",
            screenshot: Image(.onboardingPhoneAdhkar),
            // Search field and the "Every day" section.
            zoom: .init(scale: 1.25, anchor: .init(x: 0.5, y: -0.02))
        ),
    ]

    /// iPad Pro 13" (M5) simulator, portrait, 2064 × 2752.
    static let mockPad: [OnboardingItem] = [
        .init(
            id: "pad.overview",
            title: "Built for iPad",
            subtitle: "Prayer times, shortcuts and your Quran progress, side by side.",
            screenshot: Image(.onboardingPadHome)
        ),
        .init(
            id: "pad.quran",
            title: "Every Surah at a Glance",
            subtitle: "A spacious grid of all 114 surahs, and one tap to continue reading.",
            screenshot: Image(.onboardingPadQuran),
            // Pushes the sidebar out and fills the screen with "Continue reading" + the grid.
            zoom: .init(scale: 1.3, anchor: .topTrailing)
        ),
        .init(
            id: "pad.adhkar",
            title: "Adhkar for Every Moment",
            subtitle: "Find the right dhikr for any time of day, with counts to keep your place.",
            screenshot: Image(.onboardingPadAdhkar),
            // The "Every day" list in the middle column.
            zoom: .init(scale: 1.5, anchor: .init(x: 0.6, y: 0.08))
        ),
    ]

    /// macOS app window on a wallpaper, 1512 × 977 pt @2x (MacBook Air 13" proportions).
    static let mockMac: [OnboardingItem] = [
        .init(
            id: "mac.welcome",
            title: "Noor, Now on Your Mac",
            subtitle: "Prayer times, Quran and adhkar in a native Mac app.",
            screenshot: Image(.onboardingMacHome)
        ),
        .init(
            id: "mac.quran",
            title: "Read With Room to Breathe",
            subtitle: "Every surah in a clean grid, right where you left off.",
            screenshot: Image(.onboardingMacQuran),
            // "Continue reading" card and the first row of surahs.
            zoom: .init(scale: 1.5, anchor: .init(x: 0.58, y: -0.02))
        ),
        .init(
            id: "mac.adhkar",
            title: "Adhkar at Your Desk",
            subtitle: "Search and follow the adhkar for every part of your day.",
            screenshot: Image(.onboardingMacAdhkar),
            // The daily adhkar list.
            zoom: .init(scale: 1.6, anchor: .init(x: 0.55, y: -0.02))
        ),
    ]
}

extension OnboardingContent {
    static let mock = OnboardingContent(
        phone: OnboardingItem.mockPhone,
        pad: OnboardingItem.mockPad,
        mac: OnboardingItem.mockMac
    )
}
