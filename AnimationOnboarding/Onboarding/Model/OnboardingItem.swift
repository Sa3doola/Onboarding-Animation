//
//  OnboardingItem.swift
//  AnimationOnboarding
//

import SwiftUI

/// A single onboarding page: a screenshot plus the copy that explains it.
struct OnboardingItem: Identifiable {
    let id: String
    var title: LocalizedStringResource
    var subtitle: LocalizedStringResource
    var screenshot: Image
    /// Optional zoom that highlights part of the screenshot while this page is active.
    var zoom: OnboardingZoom

    init(
        id: String = UUID().uuidString,
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource,
        screenshot: Image,
        zoom: OnboardingZoom = .none
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.screenshot = screenshot
        self.zoom = zoom
    }
}

/// Describes how the device mockup zooms in on a page.
///
/// `anchor` is in unit coordinates of the screen (0...1). Values slightly outside that
/// range are allowed on iPhone/Mac, where the whole device is scaled, to push the zoomed
/// device away from the edge of the window. The iPad layout zooms *inside* the screen,
/// so it clamps the anchor to 0...1.
struct OnboardingZoom: Equatable, Sendable {
    var scale: CGFloat
    var anchor: UnitPoint

    init(scale: CGFloat, anchor: UnitPoint = .center) {
        self.scale = max(scale, 1)
        self.anchor = anchor
    }

    static let none = OnboardingZoom(scale: 1)

    var isZoomed: Bool { scale > 1 }

    var clampedAnchor: UnitPoint {
        UnitPoint(x: min(max(anchor.x, 0), 1), y: min(max(anchor.y, 0), 1))
    }
}

/// How an onboarding flow ended. Useful for analytics.
enum OnboardingResult: Equatable, Sendable {
    /// The user reached the last page and tapped the primary button.
    case completed
    /// The user tapped "Skip" while on `pageIndex`.
    case skipped(pageIndex: Int)
    /// The user closed the flow from the first page (only when `allowsDismiss` is on).
    case dismissed
}

/// Per-platform onboarding pages. Screenshots differ per device, so each platform gets its own list.
struct OnboardingContent {
    var phone: [OnboardingItem]
    var pad: [OnboardingItem]
    var mac: [OnboardingItem]

    init(phone: [OnboardingItem], pad: [OnboardingItem], mac: [OnboardingItem]) {
        self.phone = phone
        self.pad = pad
        self.mac = mac
    }

    /// Use the same pages everywhere.
    init(_ items: [OnboardingItem]) {
        self.init(phone: items, pad: items, mac: items)
    }
}
